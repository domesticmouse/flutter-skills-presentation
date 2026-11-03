# Electronics Parts Tracker V1 Specification

Status: ready-for-agent

## Problem Statement

An electronics hobbyist or hardware engineer working at a physical workbench accumulates hundreds of distinct electronic components—surface-mount passives in sample binders, integrated circuits in drawer cabinets, connectors in compartment boxes, and newly arrived supplier bags from LCSC. Without a fast, offline-first personal catalog on their phone, two friction points constantly interrupt workbench flow:

1. **Finding what is on hand and where it lives**: Answering questions like *"Do I have a 4.7kΩ 0603 resistor or a 100nF 50V X7R capacitor, how many are left, and which binder page or drawer slot is it in?"* requires digging through physical bins or searching spreadsheets where `"4k7"`, `"4.7kΩ"`, and `"4700R"` fail to match each other.
2. **Tedious catalog entry and stock upkeep**: Entering new components manually from supplier bags requires copying Manufacturer Part Numbers (MPNs), packages, electrical ratings, and datasheet links by hand, while multi-screen inventory apps require too many taps just to deduct two capacitors used on a prototype board.

## Solution

Build an offline-first personal iOS application in Flutter for cataloging **Parts**, their quantities on hand, their physical workbench storage locations (**Containers** and **Slots**), and their electrical **Specs**.

The application centers on a single-screen **Dark Command Bar & Inline Accordion** workbench interface designed for one-handed use at the lab bench:
- **Instant multi-token search with engineering unit equivalence**: Searching `"4k7 0603"` or `"0.1uF 50V"` matches **Parts** across 10 fields and automatically equates equivalent SI and EE-infix notations (`4k7` ↔ `4.7kΩ` ↔ `4700R`, `0.1uF` ↔ `100nF` ↔ `100000pF`, `3v3` ↔ `3.3V`) across **Part** names and **Specs**.
- **Two-level physical storage (`Container` → `Slot`)**: **Containers** are first-class physical storage units (e.g., `"SMD Binder #1"`, `"IC Drawer Cabinet"`), while **Slots** are on-the-fly string labels (e.g., `"Page 4"`, `"Drawer A2"`) with strict 1-to-1 `(Container, Slot)` uniqueness and natural alphanumeric sorting.
- **One-tap LCSC (`Cxxxxxx`) auto-fill**: Typing an LCSC part code (e.g., `C14663`) fetches metadata directly from LCSC's unauthenticated catalog detail endpoint to pre-fill the **Part**'s name, MPN, manufacturer, category, package/footprint, direct PDF datasheet URL, and structured electrical **Specs**, while degrading gracefully to manual entry when offline.
- **Inline stock adjustments & full detail sheets**: Tapping any **Part** card expands an inline accordion displaying its electrical **Specs** and quick stock adjustment buttons (`-10`, `-1`, `+1`, `+10`), with a full detail and edit modal sheet for setting exact quantities, editing **Specs**, or opening the PDF datasheet.
- **Zero-cloud on-device JSON persistence with iOS Files integration**: The live catalog is stored as human-readable JSON in the iOS Application Documents directory (visible directly in the iOS Files app and macOS Finder), backed by atomic writes, timestamped Share Sheet backup exports, and validated full-snapshot imports with automatic pre-import backup.

## User Stories

1. As a workbench user, I want to see my entire **Part** catalog in a high-density dark-mode list on launch, so that I can immediately scan part names, quantities, locations, packages, and LCSC codes at the bench.
2. As a workbench user, I want each **Part** row to display its quantity on hand in a high-contrast monospace badge, so that I can tell at a glance how many units I have left.
3. As a workbench user, I want a **Part**'s quantity badge to highlight in an alert color when `quantity <= lowStockThreshold` (or when `quantity == 0`), so that I can visually spot depleted or low-stock components.
4. As a workbench user, I want to tap a **Part** row to expand an inline accordion in place without losing my scroll position, so that I can inspect its electrical **Specs** and adjust its quantity immediately.
5. As a workbench user, I want quick-adjustment buttons (`-10`, `-1`, `+1`, `+10`) inside the expanded inline accordion, so that I can deduct or restock components with a single tap while building a circuit.
6. As a workbench user, I want `quantity` adjustments to clamp at `0` and never become negative, so that rapid `-10` taps cannot corrupt stock counts.
7. As a workbench user, I want to open a full **Part** Detail modal sheet from the expanded card, so that I can view all metadata (LCSC code, package, category, MPN, manufacturer, **Container** and **Slot**, low-stock threshold, workbench notes, and a full key-value table of **Specs**).
8. As a workbench user, I want a `Set…` exact quantity action in the **Part** Detail sheet, so that I can type an exact audited count without tapping increment buttons repeatedly.
9. As a workbench user, I want to tap **Open LCSC PDF Datasheet** on a **Part** with a `datasheetUrl`, so that I can view the component's pinout and electrical characteristics in an in-app browser view on my iPhone.
10. As a workbench user, I want to add a new **Part** by entering an LCSC code (`Cxxxxxx`, case-insensitive, with or without the leading `C`) and tapping **Fetch LCSC**, so that the app automatically pre-fills the **Part**'s name, MPN, manufacturer, category, package, PDF datasheet URL, and electrical **Specs**.
11. As a workbench user, I want all LCSC-fetched fields and **Specs** to populate standard editable form controls before saving, so that I can customize titles, remove noisy parameters, or add custom **Specs** before creating the **Part**.
12. As a workbench user, I want to add, edit, or remove individual `Key: Value` **Spec** rows on any **Part**, so that both LCSC-imported and manually created components have accurate electrical attributes.
13. As a workbench user, I want to create and edit **Parts** completely manually when offline or when a component was bought from another supplier (DigiKey, Mouser, local surplus), so that LCSC connectivity is never required to use the catalog.
14. As a workbench user, I want an inline warning banner with a **Jump to Part** action if I enter an `lcscCode` that already exists in my catalog, so that I can jump straight to the existing **Part** to increment its stock rather than accidentally creating a duplicate—while still being allowed to save if I intentionally want a separate entry.
15. As a workbench user, I want to create, rename, edit descriptions for, and delete physical **Containers** (e.g., `"SMD Binder #1"`, `"IC Drawer Cabinet"`) in a Manage Containers sheet, so that my digital storage model matches my physical workbench organizers.
16. As a workbench user, I want to see how many **Parts** are stored inside each **Container** in the Manage Containers sheet, so that I know how full each organizer is before modifying or deleting it.
17. As a workbench user, I want deleting a **Container** to atomically unassign any **Parts** inside it (`containerId: null, slot: null`) after confirmation, so that no **Part** is ever orphaned with a broken `containerId` reference or accidentally deleted.
18. As a workbench user, I want to assign a **Part** to a **Container** and type a **Slot** label on the fly (e.g., `"A1"`, `"Drawer 12"`, `"Page 4"`), so that I don't have to pre-configure rigid 2D grid dimensions before storing a component.
19. As a workbench user, I want the app to enforce strict 1-to-1 uniqueness for any non-empty `(Container, Slot)` pair and show an inline validation error identifying the occupying **Part** if I pick an occupied **Slot**, so that two different **Parts** are never assigned to the same physical compartment.
20. As a workbench user, I want to save a newly arrived **Part** as `Unassigned (Loose / Inbox)` (`containerId: null, slot: null`), so that I can catalog an LCSC order immediately upon arrival and put the bags into physical **Slots** later.
21. As a workbench user, I want to assign a **Part** to a **Container** with an empty **Slot** (`containerId` set, `slot: null`), so that I can represent bulk totes or un-compartmentalized boxes that hold multiple loose **Parts**.
22. As a workbench user, I want to toggle a **`By Container`** chip in the command bar to group the catalog by physical **Container**, so that I can browse everything inside each storage unit and see my `Unassigned (Loose / Inbox)` queue pinned at the top.
23. As a workbench user, I want **Parts** within each **Container** in **`By Container`** mode to be ordered by natural alphanumeric **Slot** order (`"Page 2"` before `"Page 10"`, `"A2"` before `"A10"`, with bulk slotless **Parts** last), so that the screen order matches the physical order of pages and drawers.
24. As a workbench user, I want an inline **`+ Add Slot`** button on each **Container** header in **`By Container`** mode that opens the Add **Part** sheet with that **Container** pre-selected, so that I can rapidly populate a physical organizer drawer by drawer.
25. As a workbench user, I want to search across all 10 **Part** fields (`name`, `lcscCode`, `mpn`, `manufacturer`, `category`, `package`, resolved `Container.name`, `slot`, `notes`, and `specs` keys and values) from a single top search bar, so that I never have to choose which field to query.
26. As a workbench user, I want multi-word queries (e.g., `"100nF 0603 X7R"`) to use `AND` semantics where every query token must match at least one searchable field on the **Part**, so that adding terms progressively narrows results.
27. As a workbench user, I want search to normalize Unicode electrical symbols (`µ` and `μ` → `u`, `Ω` and `ohm`/`ohms` → `r`, stripping `±`), so that typing `"10uF"` or `"100r"` on an iOS keyboard matches **Parts** stored with `"10µF"` or `"100Ω"`.
28. As a workbench user, I want search to parse SI prefixes and EE-infix notation into canonical engineering values (`4k7` ↔ `4.7kΩ` ↔ `4700R`, `0.1uF` ↔ `100nF` ↔ `100000pF`, `3v3` ↔ `3.3V`, `4r7` ↔ `4.7Ω`, `2n2` ↔ `2.2nF`), so that I can find a component regardless of how its value was formatted by LCSC or by me.
29. As a workbench user, I want bare 3-digit numbers like `"104"` to match via normal text substring (such as inside MPN `"CL10B104KB8NNNC"`) without expanding into `100nF` or `100kΩ`, so that searching for quantities, slot numbers, or LCSC codes does not produce false-positive matches.
30. As a workbench user, I want active search results ranked by match relevance—(1) exact or prefix match on `lcscCode` or `mpn`, (2) match or canonical engineering value equivalence in `name` or `specs`, (3) match in remaining fields—with alphabetical tie-breaking by `name`, so that exact part-number and value hits appear at the top.
31. As a workbench user, I want single-select filter chips (`All`, `Low Stock`, `Unassigned`, and dynamic `category` chips from categories present in my catalog) that intersect via `AND` with the active search query, so that I can slice my catalog by state or category with one tap.
32. As a workbench user, I want **`By Container`** mode to hide **Containers** with zero matching **Parts** whenever a search query or non-`All` filter chip is active (while showing empty **Containers** when `All` is selected and search is empty), so that filtered container views remain compact and scannable.
33. As a workbench user, I want category suggestions in the Add/Edit **Part** sheet drawn dynamically from categories already in my catalog, so that I can keep category naming consistent without typing from scratch.
34. As a workbench user, I want every catalog mutation saved immediately and atomically to `parts_catalog.json` in the app's iOS Documents directory without needing a manual "Save Catalog" button, so that my inventory is never lost if the app is backgrounded or terminated.
35. As a workbench user, I want the app's Documents folder exposed in the iOS Files app (**On My iPhone › Parts Tracker**) and Finder file sharing, so that I can inspect or back up `parts_catalog.json` directly from the OS.
36. As a workbench user, I want an in-app **Export Backup** action that opens the iOS Share Sheet with a timestamped file (`parts-catalog-YYYY-MM-DD.json`), so that I can save snapshots to iCloud Drive, AirDrop, or desktop storage.
37. As a workbench user, I want an in-app **Import Backup** action that lets me pick a `.json` file, validates its schema and referential integrity (`schemaVersion == 1`, valid `containerId` references, no duplicate IDs, no duplicate non-empty `(containerId, slot)` pairs), shows a confirmation dialog comparing current vs. incoming **Part** and **Container** counts and `updatedAt` timestamps, and writes a safety copy (`parts_catalog.backup.json`) before replacing the live catalog.
38. As a workbench user, I want clear, non-destructive error messages when an imported file is malformed or fails integrity validation, leaving my existing catalog completely untouched.

## Implementation Decisions

### 1. Domain Model & Glossary Alignment

All domain types use the ubiquitous language defined in `GLOSSARY.md` (`Part`, `Spec`, `Container`, `Slot`) and are implemented as immutable `@freezed` classes with `json_serializable` serialization:

- **`Container`**:
  - `id`: `String` (UUID v4)
  - `name`: `String` (required, non-empty trimmed, e.g., `"SMD Binder #1"`)
  - `description`: `String?` (optional description, e.g., `"0603 R/C sample book"`)
- **`Part`**:
  - `id`: `String` (UUID v4)
  - `name`: `String` (required, non-empty trimmed display title)
  - `quantity`: `int` (required, integer $\ge 0$, defaults to `0`)
  - `lcscCode`: `String?` (optional, normalized to uppercase `C\d+`, e.g., `"C14663"`)
  - `mpn`: `String?` (optional Manufacturer Part Number)
  - `manufacturer`: `String?` (optional brand/manufacturer name)
  - `category`: `String?` (optional component category string, e.g., `"Ceramic Capacitors"`)
  - `package`: `String?` (optional footprint/case string, e.g., `"0603"`, `"SOIC-8"`)
  - `datasheetUrl`: `String?` (optional direct PDF URL)
  - `containerId`: `String?` (optional reference to a `Container.id`)
  - `slot`: `String?` (optional trimmed compartment/page/drawer label within the `Container`; must be `null` if `containerId` is `null`)
  - `lowStockThreshold`: `int?` (optional integer $\ge 0$; a **Part** is considered low stock when `quantity <= (lowStockThreshold ?? 0)`)
  - `notes`: `String?` (optional freeform workbench notes)
  - `specs`: `Map<String, String>` (ordered key-value map of electrical/physical **Specs**, defaulting to `{}`)
- **`CatalogSnapshot`**:
  - `schemaVersion`: `int` (locked to `1` for V1)
  - `updatedAt`: `DateTime` (serialized as ISO-8601 UTC string)
  - `containers`: `List<Container>`
  - `parts`: `List<Part>`

### 2. Domain Invariants

The catalog store enforces the following invariants across all mutations and imports:
- **Non-negative stock**: `Part.quantity` is always clamped to $\ge 0$.
- **Slot requires Container**: If `Part.containerId == null`, `Part.slot` is normalized to `null` (and empty/whitespace-only strings for optional fields are normalized to `null`).
- **Strict 1-to-1 `(Container, Slot)` uniqueness**: Whenever a **Part** specifies both a `containerId` and a non-null `slot`, no other **Part** in the catalog may share the same `(containerId, slot)` pair (compared case-insensitively after trimming). Multiple **Parts** may be unassigned (`containerId: null, slot: null`) or stored in bulk in the same **Container** (`containerId != null, slot: null`).
- **Duplicate `lcscCode` warning (soft check)**: Adding or editing a **Part** with an `lcscCode` that matches another **Part** (case-insensitive) surfaces the existing **Part** so the UI can warn the user and offer to jump to it, without blocking the save.
- **Cascading Container deletion unassignment**: Deleting a **Container** atomically sets `containerId: null, slot: null` on every **Part** previously assigned to that `Container.id` within the same state update and persistence write.

### 3. Deep Module Architecture & Riverpod State Management

State management uses `flutter_riverpod` with `@riverpod` code generation (`riverpod_annotation` + `riverpod_generator`). The codebase is organized around three deep modules with minimal interfaces at their seams:

1. **Catalog Store & Persistence Seam**:
   - **`CatalogPersistence` interface**:
     - `Future<CatalogSnapshot> load()`: Reads `parts_catalog.json` if present, or returns an empty `CatalogSnapshot(schemaVersion: 1, updatedAt: now, containers: [], parts: [])` on first launch.
     - `Future<void> save(CatalogSnapshot snapshot)`: Enqueues an atomic write of `snapshot` as 2-space indented JSON (`parts_catalog.json.tmp` renamed to `parts_catalog.json`).
     - `Future<void> savePreImportBackup(CatalogSnapshot currentSnapshot)`: Writes `parts_catalog.backup.json` prior to an import replacement.
     - `Future<String> writeExportFile(CatalogSnapshot snapshot)`: Writes `parts-catalog-YYYY-MM-DD.json` to a temporary path suitable for the iOS Share Sheet.
   - **Adapters**: `FileCatalogPersistence` (production iOS Application Documents adapter using a serialized async write queue) and `InMemoryCatalogPersistence` (test adapter).
   - **`Catalog` (`@riverpod class Catalog extends _$Catalog`, `AsyncNotifier<CatalogSnapshot>`)**:
     - Exposes high-leverage mutation methods: `upsertPart(Part)`, `deletePart(String partId)`, `adjustQuantity(String partId, int delta)`, `setQuantity(String partId, int exactQuantity)`, `upsertContainer(Container)`, `deleteContainer(String containerId)`, `validateImport(String rawJson)`, and `importSnapshot(CatalogSnapshot validatedSnapshot)`.
     - Validates invariants synchronously before updating state and persisting via `CatalogPersistence`.

2. **LCSC Metadata Lookup Seam**:
   - **`LcscClient` interface**:
     - `Future<LcscPartMetadata> fetchPart(String rawCode)`: Normalizes input (`"14663"` or `"c14663"` → `"C14663"`), validates the `^C\d+$` format, and fetches metadata.
   - **`HttpLcscClient` adapter**:
     - Sends `GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=Cxxxxxx` with `Accept: application/json` and a standard browser `User-Agent` header.
     - Parses `result` (throwing a typed not-found error when `result == null` or `code != 200`):
       - `lcscCode` ← `result.productCode`
       - `name` ← first non-empty of `productDescEn`, `productIntroEn`, `productNameEn`, or `productModel`
       - `mpn` ← `productModel`
       - `manufacturer` ← `brandNameEn`
       - `category` ← `catalogName` (falling back to `parentCatalogName`)
       - `package` ← `encapStandard` (ignoring `"-"` placeholders)
       - `datasheetUrl` ← `pdfUrl`
       - `specs` ← ordered map built from `paramVOList[]` (`paramNameEn` → `paramValueEn`), stripping HTML tags/entities and skipping empty or `"-"` values.

3. **Search, Filtering & Engineering Unit Engine (`PartSearchEngine`)**:
   - Pure, stateless module consumed by a derived `@riverpod` workbench view provider.
   - **Text folding**: Lowercases text, folds `µ` (U+00B5) and `μ` (U+03BC) to `u`, folds `Ω` (U+2126), `ω` (U+03C9), and standalone unit suffixes `ohm`/`ohms` to `r`, and strips `±`.
   - **Canonical Engineering Value Parser**:
     - Parses tokens that carry an explicit SI prefix (`p`, `n`, `u`, `m`, `k`, `M`, `G`) and/or unit symbol (`R`/`Ω` for Resistance, `F` for Capacitance, `H` for Inductance, `V` for Voltage, `A` for Current, `W` for Power, `Hz` for Frequency), as well as EE-infix notation (`4k7` = $4.7 \times 10^3\ \Omega$, `4r7` = $4.7\ \Omega$, `100r` = $100\ \Omega$, `3v3` = $3.3\ \text{V}$, `2n2` = $2.2 \times 10^{-9}\ \text{F}$, `0.1uF` = $10^{-7}\ \text{F}$).
     - Converts recognized tokens into a canonical `(Dimension, double baseValue)` representation and considers two values equivalent when their `Dimension` matches (or one is dimensionless SI with a电阻/default context matching the same numeric multiplier) and `|a - b| <= 1e-6 * max(|a|, |b|)`.
     - Does **not** expand bare 3-digit EIA integers (`104`, `472`), preventing false positives against LCSC codes, quantities, and slot numbers.
   - **Multi-token `AND` search across 10 fields**:
     - Splits query string on whitespace into tokens. Every token must match at least one of the 10 searchable fields on a **Part** (`name`, `lcscCode`, `mpn`, `manufacturer`, `category`, `package`, resolved `Container.name`, `slot`, `notes`, `specs` keys & values) via folded substring or canonical engineering value equivalence on `name`/`specs`.
   - **Ranking & Natural Sorting**:
     - When the search query is non-empty, matching **Parts** are ranked by best match tier across tokens:
       - Tier 1: Exact or prefix match on `lcscCode` or `mpn`
       - Tier 2: Match (including canonical engineering value match) on `name` or `specs`
       - Tier 3: Match on remaining fields (`slot`, `Container.name`, `package`, `category`, `manufacturer`, `notes`)
       - Tie-breaker: case-insensitive alphabetical order by `name`.
     - When the search query is empty, flat view sorts alphabetically by `name`.
     - In **`By Container`** mode, `Unassigned (Loose / Inbox)` appears first, followed by **Containers** sorted alphabetically by `name`. Inside each **Container** (when search is empty), **Parts** are sorted by natural alphanumeric `slot` comparison (splitting strings into alternating non-digit and integer chunks so `"Page 2"` < `"Page 10"` and `"A2"` < `"A10"`, with `slot == null` bulk **Parts** placed last).
   - **Filter Facets**:
     - Single-select filter state (`All`, `Low Stock`, `Unassigned`, or a specific `category` string) intersects via `AND` with the search query.
     - In **`By Container`** mode, **Containers** with 0 matching **Parts** are hidden when a search query or non-`All` filter is active, and shown when `All` is selected with an empty search query.

### 4. On-Device JSON Schema & iOS Files Configuration

From the storage and schema decisions, both the live `parts_catalog.json` file and exported backup files share the exact same top-level JSON schema:

```json
{
  "schemaVersion": 1,
  "updatedAt": "2026-11-03T02:35:00.000Z",
  "containers": [
    {
      "id": "c-binder-1",
      "name": "SMD Binder #1",
      "description": "0603 Passives Sample Book"
    }
  ],
  "parts": [
    {
      "id": "p-c14663",
      "name": "100nF 50V X7R 0603 Capacitor",
      "quantity": 185,
      "lcscCode": "C14663",
      "mpn": "CC0603KRX7R9BB104",
      "manufacturer": "YAGEO",
      "category": "Ceramic Capacitors",
      "package": "0603",
      "datasheetUrl": "https://datasheet.lcsc.com/lcsc/2304140030_YAGEO-CC0603KRX7R9BB104_C14663.pdf",
      "containerId": "c-binder-1",
      "slot": "Page 4, Strip 2",
      "lowStockThreshold": 50,
      "notes": "Standard decoupling cap",
      "specs": {
        "Capacitance": "100nF",
        "Voltage Rated": "50V",
        "Tolerance": "±10%",
        "Temperature Coefficient": "X7R"
      }
    }
  ]
}
```

- **iOS `Info.plist` keys**: Enable `UIFileSharingEnabled` (`true`) and `LSSupportsOpeningDocumentsInPlace` (`true`) so `parts_catalog.json` and `parts_catalog.backup.json` are directly accessible in the iOS Files app under **On My iPhone**.
- **All-or-nothing import validation**: `validateImport(String rawJson)` verifies valid JSON object syntax, `schemaVersion == 1`, required fields and types, `quantity >= 0`, no duplicate `Container.id` or `Part.id`, every non-null `Part.containerId` exists in `containers`, and no duplicate non-empty `(containerId, slot)` pairs exist.

### 5. Workbench UI Design (Locked from Prototype)

From the validated prototype (`Variant B: Dark Command Bar & Inline Accordion`), the UI uses a dark industrial Material 3 theme (`seedColor: Color(0xFF00E5FF)`, `Brightness.dark`, scaffold background `#0E1318`, command bar `#161D24`, collapsed card `#141B22`, expanded card `#1C2631` with `#00E5FF` border, and monospace typography for quantities, `Cxxxxxx` codes, packages, and **Slots**):
- **Command Header**: Monospace search field with clear button, **Manage Containers** action, **Backup / Import** menu action, and **`+ New`** **Part** button.
- **Single-Row Horizontal Chip Strip**: Leading **`By Container`** `FilterChip` toggle, vertical divider, and `ChoiceChip`s (`All`, `Low Stock (N)`, `Unassigned (N)`, and dynamic category chips).
- **Inline Accordion Part Cards**: Tap to expand/collapse in place; expanded state shows `Key: Value` **Spec** chips, `-10`, `-1`, `+1`, `+10` stock buttons, and a **`Details & Edit`** button.
- **Modal Bottom Sheets**:
  - **Part Detail Sheet**: Badges (`lcscCode`, `package`, `category`), `name`, `mpn • manufacturer`, location & stock panel with `-10/-1/+1/+10/Set…`, `notes`, **Specs** table, **Open LCSC PDF Datasheet** button (`url_launcher`), **Edit**, and **Delete**.
  - **Add / Edit Part Sheet**: LCSC code field + **`Fetch LCSC`** button, inline duplicate `lcscCode` warning banner with **`Jump to Part`**, editable `name`, `category` (with autocomplete/chips from existing categories), `package`, `mpn`, `manufacturer`, `quantity`, `lowStockThreshold`, `Container` dropdown (`Unassigned` + all **Containers**), `Slot` field with inline `(Container, Slot)` uniqueness validation, `datasheetUrl`, `notes`, and interactive **Specs** editor (add/remove/edit `Key: Value` pairs).
  - **Manage Containers Sheet**: List of **Containers** with assigned **Part** counts, create/rename/edit description dialog, and delete confirmation noting how many **Parts** will be moved to `Unassigned`.
  - **Backup & Import Sheet / Dialogs**: **Export Backup** (Share Sheet) and **Import Backup** (File Picker → validation → confirmation dialog showing current vs. incoming **Part**/**Container** counts and `updatedAt` timestamps).

## Testing Decisions

### What Makes a Good Test
- **Test behavior through the public interface, never implementation details**: Assert on observable state transitions, returned query results, persisted JSON content, and rendered UI elements—never on private methods or internal helper state.
- **Test at the highest seam possible**: Exercise `Catalog`, `PartSearchEngine`, and the Workbench UI together through a real `ProviderContainer` or `ProviderScope`, overriding only the two external I/O boundaries (`catalogPersistenceProvider` and `lcscClientProvider`).

### Modules and Seams to Test
1. **Catalog & Search Integration via `ProviderContainer` (Primary Seam, using `InMemoryCatalogPersistence`)**:
   - Adding, editing, and deleting **Parts** and **Containers**.
   - Quantity adjustments (`-10`, `-1`, `+1`, `+10`, `setQuantity`) clamping at `0` and triggering low-stock status when `quantity <= lowStockThreshold`.
   - Enforcing strict 1-to-1 `(Container, Slot)` uniqueness while permitting multiple unassigned (`containerId: null, slot: null`) and bulk container (`containerId != null, slot: null`) **Parts**.
   - Detecting duplicate `lcscCode` entries (case-insensitive) and returning the matching existing **Part**.
   - Cascading **Container** deletion unassigning its **Parts** (`containerId: null, slot: null`) atomically.
   - Multi-token `AND` search across all 10 searchable fields, Unicode symbol folding (`µ`→`u`, `Ω`→`r`), SI & EE-infix engineering unit equivalence (`4k7` ↔ `4.7kΩ` ↔ `4700R`, `0.1uF` ↔ `100nF` ↔ `100000pF`, `3v3` ↔ `3.3V`, `4r7` ↔ `4.7Ω`), non-expansion of bare 3-digit numbers (`104`), 3-tier relevance ranking, natural alphanumeric **Slot** sorting (`"Page 2"` before `"Page 10"`), and filter chip intersection.
2. **`FileCatalogPersistence` Adapter Tests (Temporary Directory I/O Seam)**:
   - Using `Directory.systemTemp.createTemp`, verify initial empty catalog creation, atomic `.tmp` write + rename persistence, `parts_catalog.backup.json` creation before import, and strict all-or-nothing import rejection on malformed JSON, `schemaVersion != 1`, broken `containerId` references, duplicate IDs, or duplicate `(containerId, slot)` pairs.
3. **`HttpLcscClient` Adapter Tests (`package:http/testing.dart` `MockClient` Seam)**:
   - Verify `Cxxxxxx` code normalization (`"14663"`, `"c14663"` → `"C14663"`), request headers (`User-Agent`), mapping of `productModel`, `brandNameEn`, `catalogName`, `encapStandard`, `pdfUrl`, and `paramVOList` into `LcscPartMetadata` (including HTML tag/entity stripping and `"-"` filtering), and error handling for unknown codes (`result: null`) or network failures.
4. **Workbench Widget Tests (`WidgetTester` with `ProviderScope` overrides)**:
   - Verify rendering the Dark Command Bar & Inline Accordion list, searching and toggling `Low Stock` / `Unassigned` / `By Container` chips, expanding a **Part** card to adjust stock inline (`-1`, `+10`), pre-filling the Add **Part** sheet via **Fetch LCSC** (including the duplicate `lcscCode` warning banner), and managing **Containers**.

## Out of Scope

- **Projects & BOM (Bill of Materials) allocation**: Reserving or deducting **Parts** against specific PCB builds or project BOMs is deferred beyond V1.
- **Cloud sync & multi-user accounts**: No backend database, CloudKit, Firebase, or user authentication in V1; persistence is strictly on-device JSON with manual iOS Files / Share Sheet export and import.
- **Camera barcode / 2D DataMatrix scanning**: Component lookup is keyboard-based using LCSC `Cxxxxxx` codes and text search; camera scanning of supplier bags or QR labels is out of scope for V1.
- **Multi-location stock splitting**: A single **Part** entry lives in at most one `(Container, Slot)` location; splitting a single **Part** across multiple locations with per-bin sub-quantities is out of scope.

## Further Notes

- Reference materials in `.scratch/parts-tracker-v1/`:
  - Map: [map.md](./map.md)
  - LCSC endpoint research & sample payloads: [research/01-lcsc-part-metadata-lookup.md](./research/01-lcsc-part-metadata-lookup.md)
  - Validated Workbench UI prototype archive: [prototypes/04-workbench-ui-prototype.dart](./prototypes/04-workbench-ui-prototype.dart)
