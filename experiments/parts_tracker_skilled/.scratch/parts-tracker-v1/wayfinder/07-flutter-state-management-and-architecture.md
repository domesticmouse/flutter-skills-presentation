# Issue 07: Flutter state management, package dependencies, and V1 spec lock

Type: grilling
Status: resolved
Blocked by: 04, 05, 06

## Question

With the domain model ([Part domain model, categories, and electrical specifications](./02-part-domain-model-and-specs.md)), storage hierarchy ([Physical storage location hierarchy and addressing](./03-storage-location-hierarchy.md)), workbench UI ([Workbench UI flow and visual prototype](./04-workbench-ui-prototype.md)), JSON persistence ([On-device JSON persistence, schema versioning, and iOS Files export/import](./05-on-device-json-persistence-and-import-export.md)), and catalog search ([Catalog search, filtering, and engineering unit normalization](./06-search-and-unit-normalization.md)) settled, how should the Flutter app's state management, module boundaries, and external packages be structured—and are we ready to write `.scratch/parts-tracker-v1/spec.md`?

Key decisions to resolve:
1. **State management & reactive data flow**: Should the catalog state above the JSON persistence repository use built-in Flutter primitives (`ChangeNotifier` / `ValueNotifier` / `ListenableBuilder`), `riverpod`, or `bloc`/`provider`?
2. **External packages**: Confirm the minimal package set for HTTP (`http`), file paths/sharing (`path_provider`, `share_plus`, `file_picker`), UUID generation, and URL/PDF launching (`url_launcher`).
3. **Deep module boundaries**: Define the clean interface boundaries for the Catalog Store, LCSC Lookup Client, Search/Unit Normalizer, and JSON Backup/Import service, and lock `.scratch/parts-tracker-v1/spec.md`.

## Answer

1. **State Management (`flutter_riverpod` + `riverpod_generator`)**:
   - Use `flutter_riverpod` with `@riverpod` code generation (`riverpod_annotation` + `riverpod_generator` via `build_runner`).
   - Reactive state is managed by `@riverpod class Catalog extends _$Catalog` (`AsyncNotifier<CatalogSnapshot>`) alongside lightweight `@riverpod` UI filter/query notifiers (`searchQuery`, `selectedCategoryOrFacet`, `groupByContainer`) and a derived `@riverpod` `filteredWorkbenchView` provider.
2. **Domain Model Serialization (`freezed` + `json_serializable`) & External Packages**:
   - Define immutable domain models (`Part`, `Container`, `CatalogSnapshot`, `LcscPartMetadata`) using `@freezed` and `json_serializable`.
   - Runtime dependencies: `flutter_riverpod`, `riverpod_annotation`, `freezed_annotation`, `json_annotation`, `http`, `path_provider`, `share_plus`, `file_picker`, `url_launcher`, `uuid`.
   - Dev dependencies: `build_runner`, `riverpod_generator`, `freezed`, `json_serializable`.
3. **Deep Module Seams & `lib/` Layout (`codebase-design`)**:
   - **`lib/catalog/` (Catalog Store & Persistence Seam)**:
     - `CatalogPersistence` interface (`load()`, `save(CatalogSnapshot)`, `exportBackupFile(CatalogSnapshot)`, `readImportFile(String path)`) behind `catalogPersistenceProvider`, with two adapters: `FileCatalogPersistence` (iOS Application Documents `parts_catalog.json`, serialized atomic `.tmp` write + rename, pre-import `parts_catalog.backup.json`) and `InMemoryCatalogPersistence` (for fast `ProviderContainer` unit and widget tests).
     - `Catalog` (`AsyncNotifier<CatalogSnapshot>`) owns all domain invariants: strictly 1 `Part` per `(Container, Slot)`, `quantity >= 0` clamping, duplicate `lcscCode` warning lookup, cascading container-deletion unassignment (`containerId: null, slot: null`), and all-or-nothing snapshot import validation.
   - **`lib/lcsc/` (LCSC Lookup Seam)**:
     - `LcscClient` interface (`Future<LcscPartMetadata> fetchPart(String lcscCode)`) behind `lcscClientProvider`, with `HttpLcscClient` (querying `GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=Cxxxxxx`, browser `User-Agent`, HTML entity decoding, and `paramVOList` → `Specs` mapping) and fake adapters for tests.
   - **`lib/search/` (Search & Engineering Unit Engine)**:
     - Pure stateless `PartSearchEngine` module implementing Unicode folding (`µ`/`μ`→`u`, `Ω`→`r`), SI & EE-infix canonical `(Dimension, baseValue)` engineering value parsing (`4k7` ↔ `4.7kΩ`, `100nF` ↔ `0.1uF`), 10-field multi-token `AND` matching, 3-tier relevance ranking, and natural alphanumeric `Slot` sorting.
   - **`lib/ui/` (Workbench UI)**:
     - `ConsumerWidget` / `ConsumerStatefulWidget` screens and sheets implementing the Dark Command Bar & Inline Accordion workbench layout, Manage Containers sheet, and LCSC-first Add/Edit Part sheet from [Workbench UI flow and visual prototype](./04-workbench-ui-prototype.md).
