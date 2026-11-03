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
   - Store screen captures in [`artifacts/screenshots/parts_tracker_skilled/`](../../../artifacts/screenshots/parts_tracker_skilled/) with numbered, descriptive filenames (e.g., `01-catalog-list.png`, `02-category-filter.png`, `03-add-part-sheet.png`, `04-part-detail.png`).
2. **Inspect & Crop (`/crop-image`)**:
   - Run `crop.py --inspect` / `crop.py --autocrop` from [`.agents/skills/crop-image/`](../../../.agents/skills/crop-image/SKILL.md) to remove excess transparent margins or window chrome if needed.
3. **Slidev Integration (`/slidev-deck`)**:
   - Copy presentation-ready screenshots into `slides/public/images/` (e.g., `skilled-01-catalog.png`) and reference them in Act 2 slides via `/images/<filename>`.
