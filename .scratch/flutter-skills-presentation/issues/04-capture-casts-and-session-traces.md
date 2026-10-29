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
  - Raw: [recordings/raw/01-baseline.cast](../../../recordings/raw/01-baseline.cast) (`19m 19.8s` raw, `10,122` events)
  - Final (sanitized, 7 stop points injected, exit-trimmed with `3.0s` hold): [recordings/final/01-baseline.cast](../../../recordings/final/01-baseline.cast) (`19m 09.3s` raw / `17m 05.0s` at 1x with 2.0s idle cap / **`01m 13.7s` total across 8 adaptive-speed segments**)
  - Browser Test-Drive Harness: [06-baseline-cast-player.html](../prototypes/06-baseline-cast-player.html)
- **Embedded Stop Points & Adaptive Segment Speeds (`mark-cast.py --list`)**:
  - Intro (`00:00` → `00:05.3` 1x): `2x` (`2.6s` scaled)
  - `[1] 1. Project Created` (`00:05.3` → `00:11.5` 1x): `2x` (`3.1s` scaled)
  - `[2] 2. Launch agy` (`00:11.5` → `00:48.5` 1x): `2x` (`18.5s` scaled)
  - `[3] 3. Q1: Data Storage` (`00:48.5` → `00:59.5` 1x): `2x` (`5.5s` scaled)
  - `[4] 4. Q2: Features` (`00:59.5` → `01:14.3` 1x): `2x` (`7.4s` scaled)
  - `[5] 5. Q3: UI Style` (`01:14.3` → `02:37.5` 1x): `3x` (`27.7s` scaled)
  - `[6] 6. Implementation Plan` (`02:37.5` → `15:04.3` 1x): `25x` (`29.9s` scaled)
  - `[7] 7. Build Complete` (`15:04.3` → `17:05.0` 1x): `4x` (`30.2s` scaled)
- **Canonical Session Trace** (3 earlier takes moved to Trash):
  - Index: [artifacts/traces/parts_tracker_baseline/README.md](../../../artifacts/traces/parts_tracker_baseline/README.md)
  - Trace: [01-8bc45493-i-d-like-to-build-a-flutter.md](../../../artifacts/traces/parts_tracker_baseline/01-8bc45493-i-d-like-to-build-a-flutter.md)
  - Session ID: `8bc45493-3105-4834-992a-44dd7a2e2707` (`18m 31s`, `145` steps, `68` tool calls: `write_file`: 35, `run_command`: 16, `read_file`: 9, `edit_file`: 4, `ask_question`: 3, `manage_task`: 1)
  - Key Observations for Slides:
    - **Global Rule** triggered 3 sequential one-at-a-time `ask_question` calls (Steps 7, 9, 11: Local SQLite storage → Storage locations + specs/datasheets/photos → Material 3 UI).
    - Also read global Flutter plugin skill `~/.gemini/config/plugins/flutter/skills/flutter-apply-architecture-best-practices/SKILL.md` (Step 13) and wrote an ephemeral brain-folder `implementation_plan.md` (Step 19), but produced **zero repo-committed Intent Artifacts** (`GLOSSARY.md`, `docs/adr/`, or `.scratch/map.md`).

### 2. Run 2 — Skilled Run (`parts_tracker_skilled`) — **PENDING**
- Target cast: `recordings/raw/02-skilled.cast` → `recordings/final/02-skilled.cast`
- Target trace export: `artifacts/traces/parts_tracker_skilled/`

### 3. Run 3 — Comprehension Run (`parts_tracker_comprehension`) — **PENDING**
- Target cast: `recordings/raw/03-comprehension.cast` → `recordings/final/03-comprehension.cast`
- Target trace export: `artifacts/traces/parts_tracker_comprehension/`
