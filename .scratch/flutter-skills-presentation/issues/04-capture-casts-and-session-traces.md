# Capture Terminal Casts and Extract Session Traces

Type: task
Label: `wayfinder:task`
Status: open
Assignee: brett
Blocked by: 03

## Question

Following the runbook produced in [Recording Runbook and Workspace Setup Script](./03-recording-runbook-and-setup-script.md), execute the hand-recorded `asciinema` sessions for the **Baseline Run**, **Skilled Run**, and **Comprehension Run**, run the `/asciinema` trim/sanitize pipeline, and export the corresponding **Session Traces** and side-by-side comparisons via `/agy-brain-explorer` so the presentation script and Slidev deck specification can reference real session data, step counts, and generated files.

## Progress on Disk

### 1. Run 1 — Baseline Run (`parts_tracker_baseline`) — **COMPLETE & VERIFIED**
- **Terminal Casts**:
  - Raw: [recordings/raw/01-baseline.cast](../../../recordings/raw/01-baseline.cast) (`34m 08.2s` raw / `28m 14.5s` at 1x with `2.0s` idle cap, `19,349` events)
  - Final (sanitized, 15 stop points injected, cut-and-paste & prompt submit delays tightened via `--tighten-pastes`, exit-trimmed with `3.0s` hold): [recordings/final/01-baseline.cast](../../../recordings/final/01-baseline.cast) (`32m 57.2s` raw / `27m 49.1s` at 1x with `2.0s` idle cap / **`02m 33.5s` (`153.5s`) total across 16 adaptive-speed segments**, `19,289` events)
  - Browser Test-Drive Harness: [06-baseline-cast-player.html](../prototypes/06-baseline-cast-player.html)
- **Embedded Stop Points & Adaptive Segment Speeds (`mark-cast.py --list`)**:
  - Intro (`00:00` → `00:01.51` 1x): `2x` (`0.8s` scaled, warped `0.8s`) → `[1] 1. Create Project` (event `#0009`: `flutter create --platforms=ios parts_tracker_baseline` entered, before execution)
  - `[1]` → `[2] 2. Initial Git Commit` (`00:01.51` → `00:05.27` 1x): `2x` (`1.9s` scaled, warped `2.6s`, event `#0042`)
  - `[2]` → `[3] 3. Launch agy` (`00:05.27` → `00:06.57` 1x): `2x` (`0.6s` scaled, warped `3.3s`, event `#0067`)
  - `[3]` → `[4] 4. Initial Prompt` (`00:06.57` → `00:08.78` 1x): `2x` (`1.1s` scaled, warped `4.4s`, event `#0079`)
  - `[4]` → `[5] 5. Q1: Clarifying Question` (`00:08.78` → `00:50.06` 1x): `2x` (`20.6s` scaled, warped `25.0s`, event `#0516`)
  - `[5]` → `[6] 6. Q1: Options Selected` (`00:50.06` → `00:56.60` 1x): `2x` (`3.3s` scaled, warped `28.3s`, event `#0524`)
  - `[6]` → `[7] 7. Q2: Clarifying Question` (`00:56.60` → `01:07.35` 1x): `2x` (`5.4s` scaled, warped `33.7s`, event `#0620`)
  - `[7]` → `[8] 8. Q3: Clarifying Question` (`01:07.35` → `01:20.12` 1x): `2x` (`6.4s` scaled, warped `40.1s`, event `#0739`)
  - `[8]` → `[9] 9. Build Summary` (`01:20.12` → `15:30.03` 1x): `29x` (`29.3s` scaled, warped `69.4s`, event `#9103`)
  - `[9]` → `[10] 10. Build Complete` (`15:30.03` → `15:40.83` 1x): `2x` (`5.4s` scaled, warped `74.8s`, event `#9743`)
  - `[10]` → `[11] 11. Run App` (`15:40.83` → `15:41.83` 1x): `2x` (`0.5s` scaled, warped `75.3s`, event `#9745`)
  - `[11]` → `[12] 12. Clear Session (/clear)` (`15:41.83` → `16:44.18` 1x): `3x` (`20.8s` scaled, warped `96.0s`, event `#10296`)
  - `[12]` → `[13] 13. Session Cleared` (`16:44.18` → `16:45.21` 1x): `2x` (`0.5s` scaled, warped `96.6s`, event `#10304`)
  - `[13]` → `[14] 14. Codebase Review` (`16:45.21` → `16:46.21` 1x): `2x` (`0.5s` scaled, warped `97.1s`, event `#10306`)
  - `[14]` → `[15] 15. Apply Review Fixes` (`16:46.21` → `19:02.61` 1x): `5x` (`27.3s` scaled, warped `124.3s`, event `#13110`)
  - `[15]` → `[End] Fixes Verified` (`19:02.61` → `27:47.14` 1x): `18x` (`29.1s` scaled, total warped `153.5s` / `02m 33.5s`)
- **Canonical Session Traces** (2 sessions across `/clear`):
  - Index: [artifacts/traces/parts_tracker_baseline/README.md](../../../artifacts/traces/parts_tracker_baseline/README.md)
  - **Session 01 (Build & Run)**: [01-06523dd6-i-d-like-to-build-a-flutter.md](../../../artifacts/traces/parts_tracker_baseline/01-06523dd6-i-d-like-to-build-a-flutter.md)
    - Session ID: `06523dd6-c0e2-4a03-a71d-8c237c3449e0` (`19m 36s`, `94` steps, `48` tool calls: `write_file`: 21, `read_file`: 9, `run_command`: 8, `edit_file`: 7, `ask_question`: 3)
  - **Session 02 (Codebase Review & Fixes)**: [02-88556362-please-review-the-codebase.md](../../../artifacts/traces/parts_tracker_baseline/02-88556362-please-review-the-codebase.md)
    - Session ID: `88556362-faee-4403-8fce-590cf11fa961` (`12m 20s`, `81` steps, `53` tool calls: `edit_file`: 26, `read_file`: 23, `run_command`: 4)
  - Key Observations for Slides:
    - **Global Rule** triggered 3 sequential one-at-a-time `ask_question` calls in Session 01 (Steps 5, 7, 9: Features → Local JSON/CSV storage → Material 3 UI).
    - Also read 5 global Flutter/Dart plugin skills from `~/.gemini/config/plugins/flutter/skills/` (Steps 11 & 14), built a 21-file app, ran `flutter run` on the iOS Simulator, and produced **zero repo-committed Intent Artifacts** (`GLOSSARY.md`, `docs/adr/`, or `.scratch/map.md`).
    - In Session 02 (after `/clear`), `Please review the codebase` surfaced 8 architectural/correctness bugs (UI coupling in domain model `PartCategory`, `Platform.environment['HOME']` fragility, silent overwrite of corrupted JSON, concurrent write race conditions, sub-cent CSV truncation, `'Unassigned'` location rename bug, undisposed `TextEditingController`s in dialogs, uncached filter getters) and fixed all of them on `please fix`.

### 2. Run 2 — Skilled Run (`parts_tracker_skilled`) — **PENDING**
- Target cast: `recordings/raw/02-skilled.cast` → `recordings/final/02-skilled.cast`
- Target trace export: `artifacts/traces/parts_tracker_skilled/`

### 3. Run 3 — Comprehension Run (`parts_tracker_comprehension`) — **PENDING**
- Target cast: `recordings/raw/03-comprehension.cast` → `recordings/final/03-comprehension.cast`
- Target trace export: `artifacts/traces/parts_tracker_comprehension/`
