# Capture and Process Skilled Run iOS App Screenshots

Type: task
Label: `wayfinder:task`
Status: open
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
     - **Phase 2 — Built App Screens (`/implement` output)** (Pending app build):
       - Capture the final implemented screens once the **Skilled Run** app is built (e.g., catalog list, filters/search, part detail, storage containers, add/edit part flow).
2. **Inspect & Crop (`/crop-image`)**:
   - Run `crop.py --inspect` / `crop.py --autocrop` from [`.agents/skills/crop-image/`](../../../.agents/skills/crop-image/SKILL.md) to remove excess transparent margins or window chrome if needed (`OptionA.png`, `OptionB.png`, and `OptionC.png` verified at `1206x2622 px` with `0px` margin).
3. **Slidev Integration (`/slidev-deck`)**:
   - Copy presentation-ready screenshots into `slides/public/images/` (e.g., `skilled-prototype-option-a.png`, `skilled-01-catalog.png`) and reference them in Act 2 slides via `/images/<filename>`.
