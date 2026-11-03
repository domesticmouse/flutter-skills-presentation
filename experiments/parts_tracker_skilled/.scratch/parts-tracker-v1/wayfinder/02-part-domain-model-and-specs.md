# Issue 02: Part domain model, categories, and electrical specifications

Type: grilling
Status: resolved
Blocked by: 01

## Question

How should a **Part** be modeled in the catalog?

Key decisions to resolve:
1. **Identity & core fields**: What fields are required vs. optional on every Part (e.g., name, MPN, LCSC `Cxxxxxx` code, package/footprint like `0603` or `DIP-8`, quantity on hand, low-stock threshold, notes, datasheet URL)?
2. **Categories & specifications**: Should parts have fixed component categories with structured electrical fields (e.g., Resistor → resistance, tolerance, power rating; Capacitor → capacitance, voltage, dielectric), freeform tags/key-value attributes, or a hybrid?
3. **LCSC integration**: Informed by [LCSC part metadata lookup from C-code](./01-lcsc-part-metadata-lookup.md), which fields should auto-populate when an LCSC code is entered, and how should edits/overrides work?
4. **Stock tracking granularity**: Can a single Part exist across multiple Storage Locations (with per-location quantities), or does each Part live in a single Storage Location?

## Answer

1. **Identity, Stock & Location Cardinality**:
   - Each **Part** tracks a single `quantity` (integer $\ge 0$, default `0`) and lives in at most one physical `(Container, Slot)` location (`containerId?`, `slot?`), with no multi-location stock splitting.
   - **Required fields**: `id` (UUID), `name` (display title), `quantity` (integer $\ge 0$).
   - **Optional catalog & supplier fields**: `lcscCode` (normalized uppercase `Cxxxxxx`), `mpn` (Manufacturer Part Number), `manufacturer` (brand), `category` (string), `package` (footprint/case, e.g., `"0603"`, `"DIP-8"`), `datasheetUrl` (direct PDF URL), `specs` (ordered `Map<String, String>`).
   - **Optional inventory & workbench fields**: `containerId`, `slot`, `lowStockThreshold` (integer threshold where `quantity <= lowStockThreshold` flags low stock), `notes` (freeform text).
2. **Categories & Electrical Specifications (`category` and `specs`)**:
   - `category` is an optional string auto-filled from LCSC's `catalogName` (e.g., `"Ceramic Capacitors"`), with quick-pick suggestions in the UI drawn from categories already present in the catalog.
   - `specs` is an ordered key-value map (`Map<String, String>`) of parameter names to values (e.g., `{"Capacitance": "100nF", "Voltage Rated": "50V", "Tolerance": "±10%", "Temperature Coefficient": "X7R"}`), auto-populated from LCSC's `paramVOList` and freely editable as key-value rows in the UI.
3. **LCSC Auto-Fill, Overrides, and Duplicate `Cxxxxxx` Handling**:
   - Fetching a `Cxxxxxx` code in the Add/Edit Part form maps:
     - `name` ← `productDescEn ?? productIntroEn ?? productModel`
     - `mpn` ← `productModel`
     - `manufacturer` ← `brandNameEn`
     - `category` ← `catalogName`
     - `package` ← `encapStandard`
     - `datasheetUrl` ← `pdfUrl`
     - `specs` ← `{ paramNameEn: paramValueEn }` from `paramVOList` (stripping `"-"` placeholders and HTML tags)
   - All fetched values populate regular editable form fields and are persisted locally into the on-device JSON store upon saving.
   - Entering a duplicate `lcscCode` shows an inline warning linking to the existing **Part** (making it easy to jump to it and increment its quantity), without hard-blocking if the user intentionally wants a second catalog entry.
