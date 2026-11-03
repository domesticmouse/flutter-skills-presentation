# 01: Core Part catalog tracer bullet (JSON persistence, Workbench accordion list, stock adjustments, and manual Add/Edit Part)

**What to build:** An end-to-end runnable personal electronics catalog on iOS where a user can launch the Dark Command Bar & Inline Accordion workbench, browse their **Parts** with high-contrast monospace stock badges (highlighting low-stock **Parts** when `quantity <= lowStockThreshold`), tap any **Part** row to expand its inline accordion showing electrical **Specs** chips and `-10`, `-1`, `+1`, `+10` stock adjustment buttons, open the full **Part** Detail modal sheet to view all metadata, set an exact quantity (`Set…`), open a PDF `datasheetUrl` in an in-app browser view, or delete the **Part**, and manually create or edit **Parts** (including adding, editing, and removing `Key: Value` **Specs**)—with every mutation persisted atomically to the on-device JSON catalog (`schemaVersion: 1`) exposed to the iOS Files app.

From the validated prototype and schema decisions, the on-device JSON envelope is:

```json
{
  "schemaVersion": 1,
  "updatedAt": "2026-11-03T02:35:00.000Z",
  "containers": [],
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
      "containerId": null,
      "slot": null,
      "lowStockThreshold": 50,
      "notes": "Standard decoupling cap",
      "specs": {
        "Capacitance": "100nF",
        "Voltage Rated": "50V"
      }
    }
  ]
}
```

**Blocked by:** None (can start immediately)

**Status:** completed

- [x] Domain models (`Part`, `Container`, `CatalogSnapshot`) are immutable `@freezed` classes with `json_serializable` support matching the `schemaVersion: 1` JSON envelope and `GLOSSARY.md` terminology.
- [x] First launch with no existing catalog file initializes an empty `schemaVersion: 1` catalog (`containers: []`, `parts: []`); every subsequent mutation writes atomically via a serialized temp-file write + rename (`parts_catalog.json.tmp` → `parts_catalog.json`) in the iOS Application Documents directory, with `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` enabled for iOS Files app visibility.
- [x] The Workbench screen renders the dark industrial Material 3 theme (`#0E1318` background, `#161D24` command bar, `#141B22` collapsed card, `#1C2631` expanded card with `#00E5FF` border, and monospace badges for quantities, packages, and `Cxxxxxx` codes).
- [x] Each **Part** card shows its `quantity` badge (styled with alert colors when `quantity <= (lowStockThreshold ?? 0)`), `name`, and monospace subtitle, and tapping the card expands/collapses an inline accordion in place displaying `Key: Value` **Spec** chips and `-10`, `-1`, `+1`, `+10` stock buttons.
- [x] Stock adjustments update `quantity` immediately and clamp at `0` so `quantity` can never become negative.
- [x] Opening the **Part** Detail modal sheet displays all **Part** fields, a `Set…` exact quantity dialog, a full key-value **Specs** table, an **Open LCSC PDF Datasheet** action (launching `datasheetUrl` in an in-app browser view when present), and **Edit** / **Delete** actions.
- [x] The Add / Edit **Part** modal sheet supports creating and updating a **Part** manually—including `name`, `quantity`, `lowStockThreshold`, `category` (with quick-pick suggestions from existing catalog categories), `package`, `lcscCode`, `mpn`, `manufacturer`, `datasheetUrl`, `notes`, and an interactive editor to add, edit, and remove `Key: Value` **Specs**.
- [x] Automated tests exercise catalog CRUD, quantity clamping, low-stock flagging, atomic file persistence (against a temporary directory), and Workbench UI flows through the Riverpod provider seam.
