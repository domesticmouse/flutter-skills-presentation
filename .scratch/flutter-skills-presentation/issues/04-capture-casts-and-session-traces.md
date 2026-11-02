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
  - Raw: [recordings/raw/01-baseline.cast](../../../recordings/raw/01-baseline.cast) (`33m 45.7s` raw, `19,375` events)
  - Final (sanitized, 11 stop points injected, exit-trimmed with `3.0s` hold): [recordings/final/01-baseline.cast](../../../recordings/final/01-baseline.cast) (`33m 43.1s` raw / `28m 04.3s` at 1x with 2.0s idle cap / **`02m 35.3s` total across 12 adaptive-speed segments**)
  - Browser Test-Drive Harness: [06-baseline-cast-player.html](../prototypes/06-baseline-cast-player.html)
- **Embedded Stop Points & Adaptive Segment Speeds (`mark-cast.py --list`)**:
  - Intro (`00:00` → `00:04.27` 1x): `2x` (`2.1s` scaled) → `[1] 1. Project Created`
  - `[1]` → `[2] 2. Initial Git Commit` (`00:04.27` → `00:10.28` 1x): `2x` (`3.0s` scaled)
  - `[2]` → `[3] 3. Launch agy` (`00:10.28` → `00:13.34` 1x): `2x` (`1.5s` scaled)
  - `[3]` → `[4] 4. Q1: Clarifying Question` (`00:13.34` → `00:59.48` 1x): `2x` (`23.1s` scaled)
  - `[4]` → `[5] 5. Q2: Clarifying Question` (`00:59.48` → `01:16.76` 1x): `2x` (`8.6s` scaled)
  - `[5]` → `[6] 6. Q3: Clarifying Question` (`01:16.76` → `01:29.53` 1x): `2x` (`6.4s` scaled)
  - `[6]` → `[7] 7. Build Complete` (`01:29.53` → `15:50.25` 1x): `29x` (`29.7s` scaled)
  - `[7]` → `[8] 8. Run App` (`15:50.25` → `15:52.25` 1x): `2x` (`1.0s` scaled)
  - `[8]` → `[9] 9. Clear Session (/clear)` (`15:52.25` → `16:55.23` 1x): `3x` (`21.0s` scaled)
  - `[9]` → `[10] 10. Codebase Review` (`16:55.23` → `16:59.26` 1x): `2x` (`2.0s` scaled)
  - `[10]` → `[11] 11. Apply Review Fixes` (`16:59.26` → `19:18.01` 1x): `5x` (`27.7s` scaled)
  - `[11]` → `[End] Fixes Verified` (`19:18.01` → `28:02.32` 1x): `18x` (`29.1s` scaled)
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
