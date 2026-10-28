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

Validated via interactive runbook prototype and executable helper scripts:
- [03-recording-runbook.html](../prototypes/03-recording-runbook.html)
- [setup-workspaces.sh](../prototypes/setup-workspaces.sh)
- [mark-cast.py](../prototypes/mark-cast.py)

### 1. Isolated Demo Workspaces (`~/Demos/flutter-parts-experiment/`)
- Three distinctly named workspace directories so `agy-brain-explorer.py --by-project` partitions **Session Traces** automatically by project name:
  - `parts-tracker-baseline`: `git init`, zero `.agents/skills/` (only the user's **Global Rule** active).
  - `parts-tracker-skilled`: `git init`, pre-populated offline from `.agents/skills/` with the 15 Matt Pocock skills (`setup-matt-pocock-skills`, `wayfinder`, `grilling`, `domain-modeling`, `prototype`, `research`, `to-spec`, `to-tickets`, `implement`, `tdd`, `code-review`, `codebase-design`, `diagnosing-bugs`, `triage`, `wizard`).
  - `parts-tracker-comprehension`: Created via `setup-workspaces.sh clone-comprehension` (which enforces the guardrail that `parts-tracker-baseline/lib` must exist first), cloning the finished **Baseline Run** Flutter app and installing `/teach-code` and `/teach` into `.agents/skills/`.

### 2. Recording & Post-Processing Pipeline (`120x32`, `2.0s` idle cap)
- **Capture Command** (`asciinema 3.2.1`):
  ```bash
  asciinema rec --window-size 120x32 --idle-time-limit 2.0 --overwrite <recordings/raw/0X-*.cast>
  ```
- **Target Recordings**:
  - `recordings/raw/01-baseline.cast` → `recordings/final/01-baseline.cast`
  - `recordings/raw/02-skilled.cast` → `recordings/final/02-skilled.cast` (6-step chain; supports live `Ctrl+x` markers, `--append` between sessions, or post-hoc stdout boundary detection via `mark-cast.py --auto-skilled`)
  - `recordings/raw/03-comprehension.cast` → `recordings/final/03-comprehension.cast`
- **Automated Post-Processing (`setup-workspaces.sh postprocess-casts`)**:
  1. `sanitize-cast.py`: Strips accidental stdin events and scrubs environment metadata.
  2. `mark-cast.py --auto-skilled --in-place` (for `02-skilled.cast`): Relabels existing `Ctrl+x` `"m"` events or scans `"o"` stdout events to inject the 6 canonical chapter markers (`1. /setup-matt-pocock-skills`, `2. /wayfinder (Chart)`, `3. /wayfinder (Resolve)`, `4. /to-spec`, `5. /to-tickets`, `6. /implement`) across asciicast v2/v3.
  3. `trim-cast.py --in-place --hold 3.0`: Strips trailing `Ctrl+D` / shell exit sequences and holds the final frame for `3.0s`, verified via `trim-cast.py --info`.

### 3. Session Trace Extraction & Side-by-Side Comparison (`setup-workspaces.sh extract-traces`)
- Uses `uv run .agents/skills/agy-brain-explorer/scripts/agy-brain-explorer.py` to:
  1. List discovered sessions grouped by project (`--by-project`).
  2. Export per-conversation Markdown logs (`export --project parts-tracker-{baseline,skilled,comprehension} -o artifacts/traces/<project>`).
  3. Run `compare <BASELINE_SESSION> <SKILLED_SESSION>` for side-by-side step, turn, tool-invocation, and file-output diffs.
