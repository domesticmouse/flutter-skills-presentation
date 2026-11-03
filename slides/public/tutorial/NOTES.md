# Course Notes & Curriculum Roadmap

## Learner Profile
- **Prior Experience**: Experienced with React and TypeScript; has never written Dart or Flutter before.
- **Goal**: Rebuild and master the Electronics Parts Tracker (`parts_tracker_skilled`) from the ground up in `./tutorial/apps/` so they can architect and ship new Flutter apps using the same stack (Flutter + Dart 3 + Riverpod + Freezed).

## Curriculum Roadmap (`./tutorial/lessons/` & `./tutorial/apps/`)
1. **Lesson 0001 — `0001-flutter-bootstrap-and-provider-scope`**:
   - Dart & Flutter project anatomy (`pubspec.yaml` vs `package.json`, `analysis_options.yaml` vs `tsconfig.json` + ESLint).
   - Entrypoint (`void main()`, `WidgetsFlutterBinding.ensureInitialized()`, `runApp`), `ProviderScope` (vs React Context Provider), `StatelessWidget` (vs React function components), `const` constructors & `super.key`, `BuildContext`, and Material 3 dark theme setup.
   - First `testWidgets` verification (`pumpWidget`, `find.text`, `findsOneWidget` vs React Testing Library).
2. **Lesson 0002 — `0002-immutable-domain-models-with-freezed`**:
   - Dart null safety (`String?`, `??`, `!`), named parameters, factory constructors, mixins (`with`), and `part` files.
   - Building `Container`, `Part`, and `CatalogSnapshot` with `@freezed` and `json_serializable` (`build_runner`).
   - Computed getters (`isLowStock`, `isUnassigned`, `exportFileName`) and `findOccupyingSlotPart` (1-to-1 `(Container, Slot)` invariant).
3. **Lesson 0003 — `0003-persistence-seam-and-atomic-file-storage`**:
   - Abstract interfaces in Dart (`abstract interface class CatalogPersistence`), `InMemoryCatalogPersistence` test double, and `FileCatalogPersistence` with atomic `.tmp` rename and `.bak` recovery.
4. **Lesson 0004 — `0004-reactive-catalog-state-with-riverpod`**:
   - `@Riverpod(keepAlive: true)` providers and `AsyncNotifier` (`class Catalog extends _$Catalog`).
   - Part normalization, LCSC code normalization (`Cxxxxxx`), `(Container, Slot)` conflict enforcement (`SlotOccupiedException`), quantity clamping, cascading container deletion, and JSON import validation.
5. **Lesson 0005 — `0005-engineering-unit-search-and-filter-providers`**:
   - `PartSearchEngine` (engineering unit normalization: `0.1uF == 100nF == 100000pF`, `4k7 == 4.7kΩ`) and reactive `WorkbenchFilter` + derived `filteredParts` providers (vs `useMemo` / selectors).
6. **Lesson 0006 — `0006-lcsc-http-client-and-provider-injection`**:
   - `LcscClient` HTTP client, JSON parsing, custom exception types, and fake HTTP client injection in tests.
7. **Lesson 0007 — `0007-workbench-screen-and-inline-part-accordion`**:
   - `ConsumerStatefulWidget` & `ConsumerWidget` (vs `useState` + `useSelector`), `Scaffold`, dark command bar, filter chips, `By Container` grouped view, and inline accordion stock adjustment (`-10`, `-1`, `+1`, `+10`).
8. **Lesson 0008 — `0008-modal-sheets-forms-and-full-integration`**:
   - Bottom sheets (`PartDetailSheet`, `AddOrEditPartSheet`, `ManageContainersSheet`), `TextEditingController` lifecycle (vs controlled inputs / `useRef`), live LCSC fetch + duplicate detection, and end-to-end widget test suite.
