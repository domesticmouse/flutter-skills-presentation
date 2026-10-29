# Recording Runbook and Workspace Setup Script

Type: prototype
Label: `wayfinder:prototype`
Status: closed
Assignee: brett
Blocked by: 02, 05

## Question

Once the prompts and boundaries in [Demo Prompts, Q&A Script, and Run Boundaries](./02-demo-prompts-and-run-boundaries.md) and the chapter marker pipeline in [Asciinema Stop Points and Slidev Chapter Navigation](./05-asciinema-stop-points-and-slidev-navigation.md) are settled, what concrete setup script and step-by-step operator runbook should walk the human through:
1. Initializing clean, isolated directories for the **Baseline Run** (no project skills) and the **Skilled Run** / **Comprehension Run** (with Matt Pocock's skills and `/teach-code` installed),
2. Capturing each `asciinema` **Terminal Cast** with consistent terminal dimensions and idle-time limits, injecting/labeling embedded `"m"` chapter stop-points (`mark-cast.py`), and sanitizing/trimming them via `/asciinema`, and
3. Extracting and comparing the **Session Traces** from `~/.gemini/**/brain/` using `/agy-brain-explorer`?

## Resolution

Validated via the top-level operator runbook, interactive prototypes, and executable helper scripts:
- [RECORDING_RUNBOOK.md](../../../RECORDING_RUNBOOK.md)
- [03-recording-runbook.html](../prototypes/03-recording-runbook.html)
- [06-baseline-cast-player.html](../prototypes/06-baseline-cast-player.html)
- [setup-workspaces.sh](../prototypes/setup-workspaces.sh)
- [mark-cast.py](../prototypes/mark-cast.py)

### 1. Isolated Demo Workspaces (`~/Demos/flutter-parts-experiment/`)
- Three distinctly named Flutter iOS workspace directories created outside this repository so `parts_tracker_baseline` does not inherit `.agents/skills/`, and so `agy-brain-explorer.py --project` partitions **Session Traces** automatically by project name:
  - `parts_tracker_baseline`: Created live inside `01-baseline.cast` via `flutter create --platforms=ios parts_tracker_baseline` with zero project skills (only the user's **Global Rule** active).
  - `parts_tracker_skilled`: Created live inside `02-skilled.cast` via `flutter create --platforms=ios parts_tracker_skilled` followed by `npx skills@latest add mattpocock/skills`.
  - `parts_tracker_comprehension`: Cloned from the finished `parts_tracker_skilled` app (`cp -R`) before recording `03-comprehension.cast`, with `npx skills@latest add domesticmouse/skills` installed live at the start of the recording.
- Once all three runs are verified, Step 5 of [RECORDING_RUNBOOK.md](../../../RECORDING_RUNBOOK.md) copies the finished workspaces into `$REPO_ROOT/experiments/`.

### 2. Recording & Post-Processing Pipeline (`120x32`, `2.0s` idle cap)
- **Capture Command** (`asciinema 3.x`):
  ```bash
  asciinema rec --window-size 120x32 --idle-time-limit 2.0 --overwrite "$REPO_ROOT/recordings/raw/0X-<name>.cast"
  ```
- **Target Recordings**:
  - `recordings/raw/01-baseline.cast` → `recordings/final/01-baseline.cast`
  - `recordings/raw/02-skilled.cast` → `recordings/final/02-skilled.cast`
  - `recordings/raw/03-comprehension.cast` → `recordings/final/03-comprehension.cast`
- **Per-Run Post-Processing (`setup-workspaces.sh process-run <cast> <proj>`)**:
  1. `sanitize-cast.py`: Strips accidental stdin events and scrubs environment metadata (`SHELL` / `TERM` only).
  2. `mark-cast.py --auto-baseline --in-place` (for `01-baseline.cast`) or `mark-cast.py --auto-skilled --in-place` (for `02-skilled.cast`): Relabels existing `Ctrl+x` `"m"` events or scans `"o"` stdout events to inject canonical chapter stop-points immediately after the frame-completing `"o"` event before user pauses, and reports per-segment adaptive playback speeds (`>= 2x`, `<= 30s` per segment).
  3. `trim-cast.py --in-place --hold 3.0`: Strips trailing `Ctrl+D` / shell exit sequences (`press ctrl+d again to exit`) and holds the final frame for `3.0s`, verified via `trim-cast.py --info`.

### 3. Session Trace Extraction & Multi-Take Hygiene (`setup-workspaces.sh process-run` / `extract-traces`)
- Uses `uv run .agents/skills/agy-brain-explorer/scripts/agy-brain-explorer.py` to:
  1. Discover sessions for `<proj>` and export per-conversation Markdown logs (`export --project <proj> -o artifacts/traces/<proj>`).
  2. When multiple recording takes occur in the same workspace, correlate the `.cast` header `"timestamp"` against discovered session start times, move superseded takes to Trash (`agy-brain-explorer.py delete <ID>... --force`), wipe `artifacts/traces/<proj>`, and re-export so the trace index `README.md` starts cleanly at `01-`.
