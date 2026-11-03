# Capture and Process Baseline Run iOS App Screenshots

Type: task
Label: `wayfinder:task`
Status: open
Assignee: brett
Blocked by: 04

## Question

Capture, organize, and crop the iOS Simulator screen captures from the **Baseline Run** (`parts_tracker_baseline`) so they are ready to embed in **Act 1 — The Baseline Run** of the Slidev deck.

## Target Directory & Workflow

1. **Raw / Staged Captures**:
   - Store screen captures in [`artifacts/screenshots/parts_tracker_baseline/`](../../../artifacts/screenshots/parts_tracker_baseline/) with numbered, descriptive filenames (e.g., `01-catalog-list.png`, `02-category-filter.png`, `03-add-part-sheet.png`, `04-part-detail.png`).
2. **Inspect & Crop (`/crop-image`)**:
   - Run `crop.py --inspect` / `crop.py --autocrop` from [`.agents/skills/crop-image/`](../../../.agents/skills/crop-image/SKILL.md) to remove excess transparent margins or window chrome if needed.
3. **Slidev Integration (`/slidev-deck`)**:
   - Copy presentation-ready screenshots into `slides/public/images/` (e.g., `baseline-01-catalog.png`) and reference them in Act 1 slides via `/images/<filename>`.
