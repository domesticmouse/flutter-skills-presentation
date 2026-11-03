# Electronics Parts Tracker V1 Map

Label: `wayfinder:map`

## Destination

A locked V1 product & technical specification (`.scratch/parts-tracker-v1/spec.md`) for a personal iOS electronics parts tracker built with Flutter—covering the domain model (`GLOSSARY.md`), physical storage hierarchy, LCSC (`Cxxxxxx`) integration, workbench UI flows, and on-device JSON persistence with iOS Files export/import—ready to break into implementation tickets.

## Notes

- **Domain**: Personal electronics lab / workbench inventory management on iOS (Flutter).
- **Skills every session should consult**: `grilling`, `domain-modeling` (keep `GLOSSARY.md` sharp as terms crystallize), `prototype` (for UI ticket), `research` (for LCSC investigation).
- **Standing preferences**:
  - Offline-first on-device JSON storage with iOS Files / Share Sheet export & import.
  - Fast manual entry and lookup; LCSC `Cxxxxxx` codes are first-class.
  - Material 3 for UI design.

## Decisions so far

<!-- the index: one line per closed ticket, enough to judge relevance, then zoom the link for the detail the ticket holds -->
- [LCSC part metadata lookup from C-code](./wayfinder/01-lcsc-part-metadata-lookup.md): Official LCSC API (`ips.lcsc.com`) requires B2B approval and static IP whitelisting, so the app should query LCSC's unauthenticated catalog detail endpoint (`GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=Cxxxxxx`, with a browser `User-Agent`) to pre-fill MPN, brand, category, package (`encapStandard`), structured electrical specs (`paramVOList`), and direct PDF `pdfUrl`, persisting the result locally with manual-entry fallback.

- [Part domain model, categories, and electrical specifications](./wayfinder/02-part-domain-model-and-specs.md): Each `Part` tracks a single `quantity` and optional `(containerId, slot)` location alongside `name`, `lcscCode`, `mpn`, `manufacturer`, `category` (string), `package`, `datasheetUrl`, `lowStockThreshold`, `notes`, and an ordered `specs` (`Map<String, String>`) pre-filled from LCSC's `paramVOList` and editable locally; duplicate `lcscCode` entries warn and link to the existing part without hard-blocking.

- [Physical storage location hierarchy and addressing](./wayfinder/03-storage-location-hierarchy.md): Fixed 2-level hierarchy (`Container` entity → on-the-fly string `Slot` label), strictly 1 Part per `(Container, Slot)`, with optional `containerId`/`slot` for unassigned or bulk-container parts.

- [Workbench UI flow and visual prototype](./wayfinder/04-workbench-ui-prototype.md): Single-screen Dark Command Bar & Inline Accordion layout ([`lib/prototype_workbench.dart`](../../lib/prototype_workbench.dart), archived at [`prototypes/04-workbench-ui-prototype.dart`](./prototypes/04-workbench-ui-prototype.dart)) with a top monospace search omnibox, `By Container` grouping toggle, quick filter chips (`All`, `Low Stock`, `Unassigned`, plus categories), inline expandable part cards with `Specs` chips and `-10/-1/+1/+10` stock buttons, a Manage Containers sheet, and an LCSC-first Add/Edit Part sheet.

- [On-device JSON persistence, schema versioning, and iOS Files export/import](./wayfinder/05-on-device-json-persistence-and-import-export.md): Live catalog stored at `getApplicationDocumentsDirectory()/parts_catalog.json` (exposed in iOS Files via `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace`) using a `schemaVersion: 1` envelope (`schemaVersion`, `updatedAt`, `containers`, `parts`), persisted via serialized atomic temp-file write + rename (`parts_catalog.json.tmp` → `parts_catalog.json`), with Share Sheet export (`parts-catalog-YYYY-MM-DD.json`) and validated full-snapshot import (with confirmation dialog, `parts_catalog.backup.json` safety copy, and strict `(containerId, slot)` and `containerId` integrity checks).

- [Catalog search, filtering, and engineering unit normalization](./wayfinder/06-search-and-unit-normalization.md): Multi-token `AND` search across `name`, `lcscCode`, `mpn`, `manufacturer`, `category`, `package`, `Container.name`, `slot`, `notes`, and `specs` (keys & values), combining Unicode folding (`µ`→`u`, `Ω`→`r`) and canonical SI/EE-infix engineering value matching (`4k7` ↔ `4.7kΩ` ↔ `4700R`, `0.1uF` ↔ `100nF`, `3v3` ↔ `3.3V`, without bare 3-digit EIA expansion), tiered relevance ranking when searching, natural alphanumeric `slot` sorting in `By Container` mode, and `AND` intersection with the single-row filter chips (`All`, `Low Stock`, `Unassigned`, dynamic categories).

- [Flutter state management, package dependencies, and V1 spec lock](./wayfinder/07-flutter-state-management-and-architecture.md): State managed via `flutter_riverpod` + `riverpod_generator` (`@riverpod`) with `@freezed` + `json_serializable` domain models (`Part`, `Container`, `CatalogSnapshot`, `LcscPartMetadata`) and utility packages (`http`, `path_provider`, `share_plus`, `file_picker`, `url_launcher`, `uuid`), structured around three deep module seams (`lib/catalog/` with `Catalog` `AsyncNotifier` over `CatalogPersistence`, `lib/lcsc/` with `LcscClient`, and `lib/search/` with pure `PartSearchEngine`) plus `lib/ui/`.

## Not yet specified

<!-- All fog has graduated and all tickets on this map are resolved. -->

## Out of scope

- **Projects & BOM (Bill of Materials) allocation**: Reserving or deducting parts against specific electronics builds/PCBs is deferred beyond V1.
- **Cloud sync & multi-user accounts**: No backend database, CloudKit, or authentication in V1; storage is local JSON on-device with manual export/import.
- **Camera barcode / 2D DataMatrix scanning**: Entry is keyboard-based (with LCSC `Cxxxxxx` codes); camera scanning of supplier bags or bin QR labels is out of scope for V1.
