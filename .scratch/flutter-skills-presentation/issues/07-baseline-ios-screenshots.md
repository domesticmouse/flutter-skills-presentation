# Capture and Process Baseline Run iOS App Screenshots

Type: task
Label: `wayfinder:task`
Status: closed
Assignee: brett
Blocked by: 04

## Question

Capture, organize, and crop the iOS Simulator screen captures from the **Baseline Run** (`parts_tracker_baseline`) so they are ready to embed in **Act 1 — The Baseline Run** of the Slidev deck.

## Target Directory & Workflow

1. **Raw / Staged Captures**:
   - Store screen captures in [`artifacts/screenshots/parts_tracker_baseline/`](../../../artifacts/screenshots/parts_tracker_baseline/) with numbered filenames matching the 6 views built in [Session 01 (`01-06523dd6`)](../../../artifacts/traces/parts_tracker_baseline/01-06523dd6-i-d-like-to-build-a-flutter.md):
     - `01-parts-inventory.png` — **Parts Tab (`parts_list_view.dart`)**: Default home view showing the top metrics banner (total parts, low stock count, total value), search bar, horizontal category chips, and pre-populated sample parts with `-` / `+` stock buttons.
     - `02-part-detail.png` — **Part Detail Screen (`part_detail_screen.dart`)**: Tapping a sample part (e.g., `ESP32-S3-WROOM-1` or `10kΩ 1% Resistor`) showing stock adjustment controls, package/value specs, storage bin, and DigiKey/Mouser supplier details.
     - `03-add-part-sheet.png` — **Add / Edit Part Sheet (`part_form_sheet.dart`)**: Tapping the `+ Add Part` FAB showing the modal bottom sheet with category/package chips and location/supplier fields.
     - `04-storage-locations.png` — **Locations Tab (`locations_view.dart`)**: Second bottom-nav tab showing parts grouped by storage bin/drawer (`Drawer A1`, `Bin B2`, `IC Tray C1`, etc.) with distinct part and unit counts.
     - `05-restock-alerts.png` — **Restock Tab (`restock_view.dart`)**: Third bottom-nav tab highlighting low-stock and out-of-stock parts (e.g., `0.96" I2C OLED Display`) with supplier part numbers and quick-restock actions.
     - `06-import-export-sheet.png` — **JSON / CSV Import & Export Sheet (`import_export_sheet.dart`)**: Tapping the top-right import/export icon in the app bar.

## Step-by-Step `simctl` Capture Walkthrough

These use absolute paths so you can run them from any directory (including `~/Demos/flutter-parts-experiment/parts_tracker_baseline`):

1. **Home / Parts Tab** (default launch screen with dashboard banner, category chips, and parts list):
   ```bash
   xcrun simctl io booted screenshot /Users/brett/Documents/GitHub/flutter-skills-presentation/artifacts/screenshots/parts_tracker_baseline/01-parts-inventory.png
   ```
2. **Part Detail Screen** (tap a part row in the list, e.g. `10kΩ 1% Resistor` or `ESP32-S3-WROOM-1`, then capture; tap `<` back afterwards):
   ```bash
   xcrun simctl io booted screenshot /Users/brett/Documents/GitHub/flutter-skills-presentation/artifacts/screenshots/parts_tracker_baseline/02-part-detail.png
   ```
3. **Add Part Sheet** (back on the **Parts** tab, tap the floating `+ Add Part` button at the bottom right, then capture; swipe down or tap `X` to dismiss afterwards):
   ```bash
   xcrun simctl io booted screenshot /Users/brett/Documents/GitHub/flutter-skills-presentation/artifacts/screenshots/parts_tracker_baseline/03-add-part-sheet.png
   ```
4. **Locations Tab** (tap the middle **Locations** icon in the bottom navigation bar):
   ```bash
   xcrun simctl io booted screenshot /Users/brett/Documents/GitHub/flutter-skills-presentation/artifacts/screenshots/parts_tracker_baseline/04-storage-locations.png
   ```
5. **Restock Tab** (tap the right **Restock** icon with badge in the bottom navigation bar):
   ```bash
   xcrun simctl io booted screenshot /Users/brett/Documents/GitHub/flutter-skills-presentation/artifacts/screenshots/parts_tracker_baseline/05-restock-alerts.png
   ```
6. **Import / Export Sheet** (tap the **Import / Export** icon in the top-right app bar):
   ```bash
   xcrun simctl io booted screenshot /Users/brett/Documents/GitHub/flutter-skills-presentation/artifacts/screenshots/parts_tracker_baseline/06-import-export-sheet.png
   ```

2. **Inspect & Crop (`/crop-image`)**:
   - Run `crop.py --inspect` / `crop.py --autocrop` from [`.agents/skills/crop-image/`](../../../.agents/skills/crop-image/SKILL.md) to remove excess transparent margins or window chrome if needed.
3. **Slidev Integration (`/slidev-deck`)**:
   - Copy presentation-ready screenshots into `slides/public/images/` (e.g., `baseline-01-parts-inventory.png`) and reference them in Act 1 slides via `/images/<filename>`.

## Resolution

All 6 iOS Simulator screenshots captured cleanly via `xcrun simctl io booted screenshot` at `1206x2622 px` (`0px` outer margin, verified via `crop.py --inspect`):
- [`01-parts-inventory.png`](../../../artifacts/screenshots/parts_tracker_baseline/01-parts-inventory.png) (`374 KB`) — **Electronics Inventory (Parts Tab)**: Shows top 4 summary cards (`Parts: 8`, `Total ...: 434`, `Resto...: 3`, `Est. V...: $42`), search bar, category filter chips, and parts cards (`0.96" I2C OLED Display`, `100nF Ceramic Decoupling`, `10kΩ SMD Resistor`, `2N7002 N-Channel MOSFET`) with `+ Add Part` FAB.
- [`02-part-detail.png`](../../../artifacts/screenshots/parts_tracker_baseline/02-part-detail.png) (`291 KB`) — **Part Detail (`0.96" I2C OLED Display (SSD1306)`)**: Shows `0 pcs` / `Out of Stock` badge, `-10`/`-1`/`+1`/`+10` buttons (notably `+10` wraps to two lines `+1` / `0`), Specifications & Storage (`Cabinet B - Bin 3`), and Supplier & Ordering Info (`OLED-096-W-I2C`, `SSD1306-128X64-W`).
- [`03-add-part-sheet.png`](../../../artifacts/screenshots/parts_tracker_baseline/03-add-part-sheet.png) (`283 KB`) — **Add Electronic Part Form Sheet**: Shows Part Identification & Specs (`0402`, `0603`, `0805`, `1206`, `SOT-23` quick chips), Inventory & Storage Location (`Cabinet A - Drawer 2`, `Cabinet A - Drawer 4` quick chips), and Supplier quick chips (`DigiKey`, `Mouser`, `LCSC`, `Adafruit`).
- [`04-storage-locations.png`](../../../artifacts/screenshots/parts_tracker_baseline/04-storage-locations.png) (`263 KB`) — **Storage Locations Tab**: Shows bins/drawers (`Cabinet A - Drawer 2`, `Cabinet A - Drawer 4`, `Cabinet A - Drawer 5`, `Cabinet B - Bin 1`, `Cabinet B - Bin 3`, `Connector Box - Slot C2`, `SMD Book 1 - Page 12`) with part counts and `1 low/out` badges.
- [`05-restock-alerts.png`](../../../artifacts/screenshots/parts_tracker_baseline/05-restock-alerts.png) (`287 KB`) — **Restock List Tab**: Shows `OUT OF STOCK` (`0.96" I2C OLED Display`, `0 / 3 min`) and `LOW STOCK` (`BME280 Environmental`, `1 / 2 min`; `ESP32-WROOM-32E`, `4 / 5 min`) cards with copyable SKUs and `+ Restock +10` buttons.
- [`06-import-export-sheet.png`](../../../artifacts/screenshots/parts_tracker_baseline/06-import-export-sheet.png) (`363 KB`) — **Backup: Export & Import Sheet**: Shows JSON/CSV format toggle, `Copy JSON to Clipboard` button, and formatted JSON payload preview.
