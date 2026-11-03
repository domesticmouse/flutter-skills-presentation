# Capture and Process Skilled Run iOS App Screenshots

Type: task
Label: `wayfinder:task`
Status: closed
Assignee: brett
Blocked by: 04

## Question

Capture, organize, and crop the iOS Simulator screen captures from the **Skilled Run** (`parts_tracker_skilled`) so they are ready to embed and contrast against the **Baseline Run** UI in **Act 2 — The Skilled Run** of the Slidev deck.

## Target Directory & Workflow

1. **Raw / Staged Captures**:
   - Store screen captures in [`artifacts/screenshots/parts_tracker_skilled/`](../../../artifacts/screenshots/parts_tracker_skilled/) across two phases:
     - **Phase 1 — Initial `/wayfinder` Scoping Prototypes (`/prototype` ticket)** (Captured at `1206x2622 px`, `0px` outer margin):
       - [`OptionA.png`](../../../artifacts/screenshots/parts_tracker_skilled/OptionA.png) (`398 KB`) — **Variant A (`Split Tabs & Dense Stepper Rows` — "Workbench Catalog")**: Light theme with search bar (`Search value (4.7k, 100nF), package (...`), filter chips (`All`, `Low Stock`, `Unassigned`, `Passives`), dense part rows with package badge (`0603`, `DIP-8`, `SMD-41`, `SOT-223`, `SOIC-16`), location pill (`SMD Binder #1 · Page 4 · Strip 2`), LCSC code (`C25804`), inline `- / +` stepper pills, bottom variant switcher pill, and bottom navigation tabs (`Parts (7)`, `Storage (3)`).
       - [`OptionB.png`](../../../artifacts/screenshots/parts_tracker_skilled/OptionB.png) (`344 KB`) — **Variant B (`Dark Command Bar & Inline Accordion`)**: Dark workbench theme with command-bar search (`⌘ Find: "0603 4.7k"...`), `+ New` button, `Group by Container` toggle, collapsible part cards with quantity badges (`145`, `12` in red for low stock), and an expanded inline accordion (`4.7kΩ 0603 1% SMD Resistor` showing `Resistance: 4.7kΩ`, `Tolerance: ±1%`, `Power (Watts): 100mW (1/10W)`, `-10`/`-1`/`+1`/`+10` buttons, and `Full Sheet` action).
       - [`OptionC.png`](../../../artifacts/screenshots/parts_tracker_skilled/OptionC.png) (`330 KB`) — **Variant C (`Physical Container & Slot Grid` — "Bench Storage Matrix")**: Light green/mint theme with `+ Add Part` button, horizontal container selector cards (`All Bench Bins · 7 parts total`, `SMD Binder #1 · 3 occupied slots`), slot/value filter bar, and a 2-column grid of slot cards (`Page 4 · Strip 2`, `Page 2 · Strip 5`, `Drawer B3`, `Unassigned`) with `- / +` stepper controls and red low-stock borders.
     - **Phase 2 — Built App Screens (`/implement` output)** (Captured at `1206x2622 px`, `0px` outer margin):
       - [`01-workbench-catalog.png`](../../../artifacts/screenshots/parts_tracker_skilled/01-workbench-catalog.png) (`365 KB`) — **Workbench Catalog & Inline Accordion (`workbench_screen.dart`)**: Dark industrial Variant B workbench showing `⌘ Find: "4k7 0...` command bar, container/export/add buttons, filter chips (`By Container`, `All (12)`, `Low Stock (3)`, `Unassigned`), and `4.7kΩ 0603 1% SMD Resistor` expanded inline with spec pills (`Resistance: 4.7kΩ`, `Tolerance: ±1%`, `Power: 100mW`), `-10`/`-1`/`+1`/`+10` steppers, and `Details & Edit`.
       - [`02-part-detail-sheet.png`](../../../artifacts/screenshots/parts_tracker_skilled/02-part-detail-sheet.png) (`278 KB`) — **Full Part Detail Sheet (`part_detail_sheet.dart`)**: Modal bottom sheet for `4.7kΩ 0603 1% SMD Resistor` (`C23162`, `0603`, `Chip Resistors`, `MPN: RC0603FR-074K7L · YAGEO`), showing `SMD Binder #1 · Page 10`, `LOW STOCK (≤20)` badge, `QUANTITY ON HAND: 12`, `-10`/`-1`/`+1`/`+10` + `Set...` buttons (clean single-line pills with no text wrapping), `WORKBENCH NOTES` (`I2C SDA/SCL pull-up resistor`), and `ELECTRICAL SPECS (3)`.
       - [`03-add-part-lcsc-lookup.png`](../../../artifacts/screenshots/parts_tracker_skilled/03-add-part-lcsc-lookup.png) (`301 KB`) — **Add Part Sheet with Live LCSC Lookup (`add_or_edit_part_sheet.dart`)**: Shows live `Fetch LCSC` result for `C2878713` (`TL074HIDR` by `TI`, `SOIC-14`, `26mA Four channels 1mV 20V/us 1pA 105d...`, `Instrumentation, O...`, and auto-populated `https://datasheet.lcsc.com/datasheet/pdf/...` URL) alongside `Container` / `Slot` pickers and category chips.
       - [`04-by-container-storage-view.png`](../../../artifacts/screenshots/parts_tracker_skilled/04-by-container-storage-view.png) (`375 KB`) — **Grouped `By Container` Storage View (`workbench_screen.dart`)**: Shows the `By Container` toggle active with pinned `Unassigned (Loose / Inbox)` (`CH340C`, `USB Type-C 16-Pin`), `Connectors & Headers Tote` (`JST-SH 1.0mm 4-Pin Qwiic / STEMMA QT`), and `IC Drawer Cabinet` (`RP2040` in `Drawer A1`, `ESP32-S3-WROOM-1-N8R2` in `Drawer A2`, `NE555P` in `Drawer A10`) with inline `+ Add Slot` actions on each container header.
       - [`05-manage-containers-sheet.png`](../../../artifacts/screenshots/parts_tracker_skilled/05-manage-containers-sheet.png) (`321 KB`) — **Manage Physical Containers Sheet (`manage_containers_sheet.dart`)**: Modal sheet listing all 4 physical **Containers** (`SMD Binder #1` · `4 parts`, `IC Drawer Cabinet` · `3 parts`, `Passives & Power Grid Box A` · `2 parts`, `Connectors & Headers Tote` · `1 parts`) with edit/delete actions and bottom `New Container` / `Description` / `Add` bar.
       - [`06-backup-import-menu.png`](../../../artifacts/screenshots/parts_tracker_skilled/06-backup-import-menu.png) (`379 KB`) — **Backup & Import Command Bar Menu (`workbench_screen.dart`)**: Shows the top-bar `Export Backup` and `Import Backup` popup menu overlaid on the `By Container` workbench view.
       - [`07-backup-export-sheet.png`](../../../artifacts/screenshots/parts_tracker_skilled/07-backup-export-sheet.png) (`755 KB`) — **iOS Native Share Sheet for Catalog Backup (`share_plus`)**: Bonus capture showing the native iOS share sheet invoked by `Export Backup` (`Parts Tracker Catalog Backup · JSON · 9 KB` with `Copy` and `Save to Files` actions).
2. **Inspect & Crop (`/crop-image`)**:
   - Run `crop.py --inspect` / `crop.py --autocrop` from [`.agents/skills/crop-image/`](../../../.agents/skills/crop-image/SKILL.md) to remove excess transparent margins or window chrome if needed (all 10 PNGs verified at `1206x2622 px` with `0px` margin).
3. **Slidev Integration (`/slidev-deck`)**:
   - Copy presentation-ready screenshots into `slides/public/images/` (e.g., `skilled-prototype-option-a.png`, `skilled-01-workbench-catalog.png`) and reference them in Act 2 slides via `/images/<filename>`.

## Resolution

All 10 iOS Simulator screenshots (3 Phase 1 `/prototype` options + 7 Phase 2 final built app views, including the bonus native iOS Share Sheet capture `07-backup-export-sheet.png`) are captured and verified in [`artifacts/screenshots/parts_tracker_skilled/`](../../../artifacts/screenshots/parts_tracker_skilled/) at `1206x2622 px` (`0px` outer margin).
