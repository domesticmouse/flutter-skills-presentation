# Operator Recording Runbook: Three-Run Flutter Experiment

This document lists the step-by-step commands, prompts, and canonical Q&A answers to run the three-part experiment in a standalone directory, record the `asciinema` **Terminal Casts**, and copy the resulting directory back into this repository when finished.

---

## Overview of the Standalone Directory Layout

Everything runs inside a single standalone directory outside this repo (`~/Demos/flutter-parts-experiment` by default, or any path you prefer):

```text
~/Demos/flutter-parts-experiment/
├── tools/
│   └── domesticmouse-skills/      # Cloned in Step 1 for sanitize-cast.py, trim-cast.py & agy-brain-explorer.py
├── recordings/
│   ├── raw/
│   │   ├── 01-baseline.cast
│   │   ├── 02-skilled.cast
│   │   └── 03-comprehension.cast
│   └── final/                     # Sanitized & exit-trimmed .cast files verified after each run
│       ├── 01-baseline.cast
│       ├── 02-skilled.cast
│       └── 03-comprehension.cast
├── traces/                        # Exported per-session Agy Markdown logs verified after each run
│   ├── parts_tracker_baseline/
│   ├── parts_tracker_skilled/
│   └── parts_tracker_comprehension/
├── brain-traces/                  # Raw ~/.gemini/**/brain JSONL transcripts snapshotted after each run
├── parts_tracker_baseline/        # Run 1: Created via flutter create --platforms=ios (no skills)
├── parts_tracker_skilled/         # Run 2: Created via flutter create --platforms=ios + npx skills@latest add mattpocock/skills
└── parts_tracker_comprehension/   # Run 3: Cloned from Skilled Run + npx skills@latest add domesticmouse/skills
```

---

## Step 0: Pre-Flight Tool & Environment Check

Because you are running this on another machine, run these checks before starting the recordings to confirm every required CLI tool, SDK, and configuration is present and working:

### 0.1 Verify Flutter & iOS Toolchain (`flutter doctor`)
```bash
flutter --version
flutter doctor
```
- Confirm **Flutter**, **Xcode** (for iOS development), and **CocoaPods** show `[✓]`.
- Optional quick smoke test that `flutter create --platforms=ios` succeeds cleanly without first-run analytics prompts:
  ```bash
  flutter create --platforms=ios /tmp/flutter_preflight_test && rm -rf /tmp/flutter_preflight_test
  ```

### 0.2 Verify `asciinema` Version & `--window-size` Flag (`>= 3.0`)
The runbook uses `asciinema 3.x` flags (`--window-size 120x32`) and live `Ctrl+x` markers (`"m"` events). Verify the installed version and run a 1-second non-interactive smoke test:
```bash
asciinema --version
asciinema rec --window-size 120x32 --idle-time-limit 2.0 --overwrite -c "echo 'asciinema pre-flight OK'" /tmp/preflight.cast && rm -f /tmp/preflight.cast
```
- If `asciinema` is missing or still on `2.x` (where `--window-size` is not recognized and `Ctrl+x` markers aren't supported), upgrade via Homebrew:
  ```bash
  brew install asciinema   # or: brew upgrade asciinema
  ```

### 0.3 Verify Node.js, `npx`, and `skills` CLI
Run 2 and Run 3 invoke `npx skills@latest add ...` live on camera. Check `node`/`npx` and pre-warm the `skills` package cache so it doesn't prompt to install `skills@latest` during the recording:
```bash
node --version
npx --version
npx --yes skills@latest --version
```

### 0.4 Verify Antigravity CLI (`agy`) & Your Global Rule
Confirm `agy` is on `PATH` and authenticated, and verify your **Global Rule** (`When something is unclear, please ask clarifying questions, one at a time.`) is present in `$HOME/.gemini/config/AGENTS.md` on this machine so Run 1 (**Baseline Run**) exhibits the expected one-at-a-time questioning behavior:
```bash
which agy
agy --version
cat "$HOME/.gemini/config/AGENTS.md"
```

### 0.5 Verify `git`, `python3`, and `uv`
`git` is used by `/wayfinder` and `/implement`, `python3` is used by `asciinema` cast scripts and `/teach-code` (`build.py --check`), and `uv` runs `agy-brain-explorer.py` after each recording to inspect and export your Antigravity logs:
```bash
git --version
python3 --version
uv --version
```
- If `uv` is missing, install it via Homebrew (`brew install uv`) or `curl -LsSf https://astral.sh/uv/install.sh | sh`.

---

## Step 1: Create the Standalone Experiment Directory & Post-Recording Helper

Run the following in your terminal to create `$EXP_DIR`, clone `domesticmouse/skills` into an isolated `$EXP_DIR/tools/` folder (so `.agents/skills` is **not** created in the parent directory where it could affect the Baseline Run), and generate the `$EXP_DIR/tools/process-run.sh` verification script:

```bash
export EXP_DIR="$HOME/Demos/flutter-parts-experiment"
mkdir -p "$EXP_DIR/recordings/raw" "$EXP_DIR/recordings/final" "$EXP_DIR/traces" "$EXP_DIR/brain-traces" "$EXP_DIR/tools"

# Clone domesticmouse/skills into $EXP_DIR/tools/ for sanitize-cast.py, trim-cast.py, and agy-brain-explorer.py
if [ ! -d "$EXP_DIR/tools/domesticmouse-skills" ]; then
  git clone --depth 1 https://github.com/domesticmouse/skills.git "$EXP_DIR/tools/domesticmouse-skills"
fi

# Pre-warm uv dependency cache for agy-brain-explorer.py
uv run "$EXP_DIR/tools/domesticmouse-skills/skills/agy-brain-explorer/scripts/agy-brain-explorer.py" --help >/dev/null

# Create a helper script to process & inspect each run immediately after recording
cat << 'EOF' > "$EXP_DIR/tools/process-run.sh"
#!/usr/bin/env bash
set -euo pipefail

EXP_DIR="${EXP_DIR:-$HOME/Demos/flutter-parts-experiment}"
CAST_NAME="${1:?Usage: process-run.sh <cast-filename.cast> <project-dir-name>}"
PROJECT_NAME="${2:?Usage: process-run.sh <cast-filename.cast> <project-dir-name>}"

SKILLS_ROOT="$EXP_DIR/tools/domesticmouse-skills/skills"
SANITIZE_PY="$SKILLS_ROOT/asciinema/scripts/sanitize-cast.py"
TRIM_PY="$SKILLS_ROOT/asciinema/scripts/trim-cast.py"
BRAIN_PY="$SKILLS_ROOT/agy-brain-explorer/scripts/agy-brain-explorer.py"

RAW_CAST="$EXP_DIR/recordings/raw/$CAST_NAME"
FINAL_CAST="$EXP_DIR/recordings/final/$CAST_NAME"
TRACE_OUT="$EXP_DIR/traces/$PROJECT_NAME"

echo "=================================================================="
echo "1. Processing & Inspecting Asciinema Cast: $CAST_NAME"
echo "=================================================================="
if [ ! -f "$RAW_CAST" ]; then
  echo "[ERROR] Raw cast not found at: $RAW_CAST"
  exit 1
fi

python3 "$SANITIZE_PY" "$RAW_CAST" "$FINAL_CAST"
python3 "$TRIM_PY" "$FINAL_CAST" --in-place --hold 3.0 || true
python3 "$TRIM_PY" "$FINAL_CAST" --info

echo ""
echo "--- Embedded Ctrl+x Chapter Markers ('m' events) ---"
python3 - "$FINAL_CAST" << 'PYEOF'
import json, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    lines = [l.strip() for l in f if l.strip() and not l.strip().startswith("#")]
header = json.loads(lines[0])
version = int(header.get("version", 2))
idle = header.get("idle_time_limit")
idle_cap = float(idle) if idle is not None else None
raw_t = eff_t = prev_raw = 0.0
markers = []
for idx, line in enumerate(lines[1:]):
    ev = json.loads(line)
    t_val, code = float(ev[0]), str(ev[1])
    label = ev[2] if len(ev) > 2 else ""
    dt = t_val if version == 3 else (t_val - prev_raw)
    raw_t = (raw_t + dt) if version == 3 else t_val
    prev_raw = raw_t
    eff_t += min(dt, idle_cap) if idle_cap is not None else dt
    if code == "m":
        markers.append((idx, raw_t, eff_t, label))
if not markers:
    print("  (no 'm' markers found)")
else:
    for i, (idx, rt, et, lbl) in enumerate(markers, 1):
        print(f"  [{i}] event #{idx:04d} | raw={rt:6.2f}s | playback={et:6.2f}s | label={lbl!r}")
PYEOF

echo ""
echo "=================================================================="
echo "2. Discovering & Exporting Agy Session Logs: $PROJECT_NAME"
echo "=================================================================="
uv run "$BRAIN_PY" --project "$PROJECT_NAME"
mkdir -p "$TRACE_OUT"
uv run "$BRAIN_PY" export --project "$PROJECT_NAME" -o "$TRACE_OUT"
echo ""
echo "Exported Markdown session logs in $TRACE_OUT:"
ls -la "$TRACE_OUT"

echo ""
echo "=================================================================="
echo "3. Snapshotting Raw ~/.gemini/**/brain Traces"
echo "=================================================================="
for bdir in ~/.gemini/*/brain ~/.gemini/brain; do
  if [ -d "$bdir" ]; then
    parent_name="$(basename "$(dirname "$bdir")")"
    mkdir -p "$EXP_DIR/brain-traces/$parent_name"
    cp -R "$bdir" "$EXP_DIR/brain-traces/$parent_name/"
  fi
done
echo "[OK] Verification & snapshot complete for $CAST_NAME ($PROJECT_NAME)."
EOF
chmod +x "$EXP_DIR/tools/process-run.sh"
cd "$EXP_DIR"
```

---

## Canonical Q&A Answers (Used Across Runs 1 & 2)

Keep these answers handy so both the **Baseline Run** and **Skilled Run** receive identical product requirements when `agy` asks clarifying questions:

| Topic | Canonical Answer to Copy/Paste |
| :--- | :--- |
| **Parts / Categories** | `Hobbyist/maker electronics parts: resistors, capacitors, ICs/microcontrollers, sensors, LEDs, and breakout boards.` |
| **Attributes per Part** | `Part name/number, category, quantity on hand, storage location (e.g., drawer/bin label), and a freeform specs/notes field (e.g., "10kΩ 1%", "3.3V I2C").` |
| **Core Workflows** | `Browse and search parts, filter by category, increment/decrement quantity quickly, and add/edit parts. No barcode scanning, BOM/project tracking, or supplier API integration.` |
| **Persistence** | `Local on-device storage only (no cloud sync or user accounts), pre-populated with a small set of sample parts on first launch.` |
| **UI Style** | `Standard clean iOS look (Cupertino or adaptive Material 3).` |
| **Issue Tracker** *(Run 2 only)* | `Local Markdown (.scratch/)` |
| **Domain Modeling** *(Run 2 only)* | `Single context (GLOSSARY.md + docs/adr/)` |

---

## Step 2: Record Run 1 — Baseline Run (`01-baseline.cast`)

### 2.1 Start Recording in `$EXP_DIR`
```bash
cd "$EXP_DIR"
asciinema rec --window-size 120x32 --idle-time-limit 2.0 --overwrite "$EXP_DIR/recordings/raw/01-baseline.cast"
```

### 2.2 Create the Flutter Project & Launch `agy`
Inside the recorded shell:

1. **Create the Flutter project**:
   ```bash
   flutter create --platforms=ios parts_tracker_baseline
   ```
2. **Move into the project**:
   ```bash
   cd parts_tracker_baseline
   ```
3. **Start Antigravity in the Flutter project**:
   ```bash
   agy
   ```
4. **Paste the initial prompt**:
   ```text
   I'd like to build a Flutter app for iOS that enables me to track my electronics parts
   ```
5. Answer `agy`'s one-at-a-time clarifying questions using the **Canonical Q&A Answers** table above.
6. Let `agy` build the Flutter iOS app and verify `flutter analyze` / `flutter test`.
7. Exit `agy` and press `Ctrl+D` (or type `exit`) to finish the `asciinema` recording.

### 2.3 Process, Inspect & Decide: Good Capture or Redo Run 1?
Immediately after exiting the recording shell, run the post-recording processor to sanitize/trim `01-baseline.cast` and export the Antigravity session logs for `parts_tracker_baseline`:

```bash
"$EXP_DIR/tools/process-run.sh" 01-baseline.cast parts_tracker_baseline
```

**Verify the capture:**
1. **Check the Asciinema cast**:
   - Confirm `recordings/final/01-baseline.cast` has non-zero stdout events and expected playback duration.
   - Quick visual replay at 2x speed:
     ```bash
     asciinema play -s 2.0 -i 1.0 "$EXP_DIR/recordings/final/01-baseline.cast"
     ```
2. **Check the exported Agy Markdown logs**:
   - Inspect the session summary and exported Markdown trace:
     ```bash
     cat "$EXP_DIR/traces/parts_tracker_baseline/README.md"
     ```
   - Confirm `agy` asked its clarifying questions one at a time (per your Global Rule), built the app, and did **not** produce architecture artifacts (`GLOSSARY.md` or `docs/adr/`).
3. **Check the Flutter project**:
   ```bash
   cd "$EXP_DIR/parts_tracker_baseline" && flutter analyze && flutter test
   ```

> **If you need to REDO Run 1**: Clean up both the project directory **and** the aborted `parts_tracker_baseline` Agy brain sessions (so failed sessions don't pollute your exported logs), then repeat from **Step 2.1**:
> ```bash
> uv run "$EXP_DIR/tools/domesticmouse-skills/skills/agy-brain-explorer/scripts/agy-brain-explorer.py" delete --project "parts_tracker_baseline" --force
> rm -rf "$EXP_DIR/parts_tracker_baseline" "$EXP_DIR/traces/parts_tracker_baseline" "$EXP_DIR/recordings/raw/01-baseline.cast" "$EXP_DIR/recordings/final/01-baseline.cast"
> ```

---

## Step 3: Record Run 2 — Skilled Run (`02-skilled.cast`)

> **Adding Asciinema Stop Points**: Press **`Ctrl+x`** at each stop-point instruction below to insert an embedded `"m"` marker into `02-skilled.cast`.

### 3.1 Start Recording in `$EXP_DIR`
```bash
cd "$EXP_DIR"
asciinema rec --window-size 120x32 --idle-time-limit 2.0 --overwrite "$EXP_DIR/recordings/raw/02-skilled.cast"
```

### 3.2 Execute the Skilled Run Sequence Inside the Recording

1. **Create the Flutter project**:
   ```bash
   flutter create --platforms=ios parts_tracker_skilled
   ```
2. **Move into the project**:
   ```bash
   cd parts_tracker_skilled
   ```
3. **Add asciinema stop point**: Press **`Ctrl+x`**.
4. **Install all of Matt Pocock's skills**:
   ```bash
   npx skills@latest add mattpocock/skills
   ```
5. **Add asciinema stop point**: Press **`Ctrl+x`**.
6. **Start Antigravity in the Flutter project**:
   ```bash
   agy
   ```
7. **Add asciinema stop point**: Press **`Ctrl+x`**.
8. **Prompt Antigravity with `/wayfinder`**:
   ```text
   /wayfinder I'd like to build a Flutter app for iOS that enables me to track my electronics parts
   ```
9. **Answer questions** using the **Canonical Q&A Answers** table above until the map and initial decision tickets are created.
10. **Issue `/clear` in `agy`** to start a new conversation:
    ```text
    /clear
    ```
11. **Issue `/wayfinder`** to start the next round of questions on the next open decision ticket:
    ```text
    /wayfinder
    ```
12. **Answer questions** to resolve the decision ticket.
13. **Issue `/clear`** to start a new conversation:
    ```text
    /clear
    ```
14. **Add asciinema stop point**: Press **`Ctrl+x`**.
15. **Repeat steps 11 through 14** (`/wayfinder` → answer questions → `/clear` → **`Ctrl+x`**) until all `/wayfinder` decision tickets are complete.
16. **Complete the build of the app** (e.g., `/to-spec` → `/to-tickets` → `/implement`, with `/clear` and **`Ctrl+x`** between stages as appropriate) until the Flutter app is built and verified.
17. Exit `agy` and press `Ctrl+D` (or `exit`) to save `02-skilled.cast`.

### 3.3 Process, Inspect & Decide: Good Capture or Redo Run 2?
Immediately after exiting the recording shell, run the post-recording processor to sanitize/trim `02-skilled.cast`, list your `Ctrl+x` chapter markers, and export all `/clear`-separated Antigravity session logs for `parts_tracker_skilled`:

```bash
"$EXP_DIR/tools/process-run.sh" 02-skilled.cast parts_tracker_skilled
```

**Verify the capture:**
1. **Check the Asciinema cast & `Ctrl+x` stop points**:
   - Confirm the output lists your `"m"` markers at the expected timestamps.
   - Replay in marker-pause mode (`-m`, press `Space` or `]` to jump between markers):
     ```bash
     asciinema play -m -s 2.0 -i 1.0 "$EXP_DIR/recordings/final/02-skilled.cast"
     ```
2. **Check the exported Agy Markdown logs**:
   - Review the multi-session index (each `/clear` creates a distinct conversation trace in `traces/parts_tracker_skilled/`):
     ```bash
     cat "$EXP_DIR/traces/parts_tracker_skilled/README.md"
     ```
3. **Check the Skilled Run artifacts & tests**:
   ```bash
   cd "$EXP_DIR/parts_tracker_skilled"
   ls -la GLOSSARY.md docs/adr/ .scratch/
   flutter analyze && flutter test
   ```

> **If you need to REDO Run 2**: Clean up both the project directory **and** the aborted `parts_tracker_skilled` Agy brain sessions, then repeat from **Step 3.1**:
> ```bash
> uv run "$EXP_DIR/tools/domesticmouse-skills/skills/agy-brain-explorer/scripts/agy-brain-explorer.py" delete --project "parts_tracker_skilled" --force
> rm -rf "$EXP_DIR/parts_tracker_skilled" "$EXP_DIR/traces/parts_tracker_skilled" "$EXP_DIR/recordings/raw/02-skilled.cast" "$EXP_DIR/recordings/final/02-skilled.cast"
> ```

---

## Step 4: Clone Skilled Run App & Record Run 3 — Comprehension Run (`03-comprehension.cast`)

### 4.1 Clone the Finished Skilled Run App
Before starting the recording, make a clean copy of the finished Skilled Run directory (`parts_tracker_skilled`) as the starting point:
```bash
cd "$EXP_DIR"
rm -rf "$EXP_DIR/parts_tracker_comprehension"
cp -R "$EXP_DIR/parts_tracker_skilled" "$EXP_DIR/parts_tracker_comprehension"
```

### 4.2 Start Recording
```bash
cd "$EXP_DIR/parts_tracker_comprehension"
asciinema rec --window-size 120x32 --idle-time-limit 2.0 --overwrite "$EXP_DIR/recordings/raw/03-comprehension.cast"
```

### 4.3 Install Skills & Run `/teach-code` Inside the Recording

1. **Install skills live in the recording**:
   ```bash
   npx skills@latest add domesticmouse/skills
   ```
2. **Add asciinema stop point**: Press **`Ctrl+x`**.
3. **Launch `agy`**:
   ```bash
   agy
   ```
4. **Add asciinema stop point**: Press **`Ctrl+x`**.
5. **Paste the `/teach-code` prompt**:
   ```text
   /teach-code I know React for mobile development, and I just had AI generate this Flutter iOS electronics parts tracker app for me. Help me understand how this codebase works and teach me the Flutter and Dart concepts behind it.
   ```

Use these responses when `/teach-code` interviews you:
- **Prior Background**: `Comfortable with React mobile development (components, props, hooks/useState, JSX), brand new to Dart and Flutter widget trees and state management.`
- **Mission Goal**: `Understand and confidently modify every file in this electronics parts catalog app without relying blindly on the AI.`

**Stopping Boundary**: Stop once `/teach-code` scaffolds `./tutorial/` (`MISSION.md`, `RESOURCES.md`, `NOTES.md`, `reference/GLOSSARY.md`, `build.py`), authors and verifies **Lesson 0001** (including its companion project under `tutorial/apps/0001-...`), and compiles `tutorial/index.html` and `tutorial/lessons/0001-*.html` cleanly via `build.py --check`.

Exit `agy` and press `Ctrl+D` (or `exit`) to save `03-comprehension.cast`.

### 4.4 Process, Inspect & Decide: Good Capture or Redo Run 3?
Immediately after exiting the recording shell, run the post-recording processor to sanitize/trim `03-comprehension.cast`, verify `Ctrl+x` markers, and export the Antigravity session logs for `parts_tracker_comprehension`:

```bash
"$EXP_DIR/tools/process-run.sh" 03-comprehension.cast parts_tracker_comprehension
```

**Verify the capture:**
1. **Check the Asciinema cast & `Ctrl+x` stop points**:
   ```bash
   asciinema play -m -s 2.0 -i 1.0 "$EXP_DIR/recordings/final/03-comprehension.cast"
   ```
2. **Check the exported Agy Markdown logs**:
   ```bash
   cat "$EXP_DIR/traces/parts_tracker_comprehension/README.md"
   ```
3. **Check the generated `/teach-code` curriculum & HTML build**:
   ```bash
   cd "$EXP_DIR/parts_tracker_comprehension"
   python3 tutorial/build.py --check
   ls -la tutorial/index.html tutorial/lessons/ tutorial/apps/
   ```

> **If you need to REDO Run 3**: Clean up the `parts_tracker_comprehension` directory and its Agy brain sessions (leaving `parts_tracker_skilled` untouched), then repeat from **Step 4.1**:
> ```bash
> uv run "$EXP_DIR/tools/domesticmouse-skills/skills/agy-brain-explorer/scripts/agy-brain-explorer.py" delete --project "parts_tracker_comprehension" --force
> rm -rf "$EXP_DIR/parts_tracker_comprehension" "$EXP_DIR/traces/parts_tracker_comprehension" "$EXP_DIR/recordings/raw/03-comprehension.cast" "$EXP_DIR/recordings/final/03-comprehension.cast"
> ```

---

## Step 5: Copy `$EXP_DIR` Back into This Repo

Because `process-run.sh` already sanitized/trimmed your casts into `$EXP_DIR/recordings/final/`, exported your per-session Markdown logs into `$EXP_DIR/traces/`, and snapshotted `~/.gemini/**/brain` into `$EXP_DIR/brain-traces/`, simply transfer `$EXP_DIR` back to this machine and copy its contents into this repository:

```bash
export REPO_ROOT="/Users/brett/Documents/GitHub/flutter-skills-presentation"
export EXP_DIR="$HOME/Demos/flutter-parts-experiment"

# Copy raw and final processed .cast recordings into repo recordings/
mkdir -p "$REPO_ROOT/recordings/raw" "$REPO_ROOT/recordings/final"
cp -R "$EXP_DIR/recordings/raw/"*.cast "$REPO_ROOT/recordings/raw/"
cp -R "$EXP_DIR/recordings/final/"*.cast "$REPO_ROOT/recordings/final/" 2>/dev/null || true

# Copy the completed project directories into repo experiments/
mkdir -p "$REPO_ROOT/experiments"
cp -R "$EXP_DIR/parts_tracker_baseline" "$REPO_ROOT/experiments/"
cp -R "$EXP_DIR/parts_tracker_skilled" "$REPO_ROOT/experiments/"
cp -R "$EXP_DIR/parts_tracker_comprehension" "$REPO_ROOT/experiments/"

# Copy exported Markdown traces and raw brain-traces into repo artifacts/
mkdir -p "$REPO_ROOT/artifacts/traces"
if [ -d "$EXP_DIR/traces" ]; then
  cp -R "$EXP_DIR/traces/"* "$REPO_ROOT/artifacts/traces/" 2>/dev/null || true
fi
if [ -d "$EXP_DIR/brain-traces" ]; then
  cp -R "$EXP_DIR/brain-traces" "$REPO_ROOT/artifacts/"
fi
```

---

## Step 6: Post-Process Casts & Extract Session Traces

After copying the directory back into this repo, either run these commands or tell the agent in this session that the files have been copied back:

```bash
cd "$REPO_ROOT"

# 1. Sanitize casts, inspect/label Ctrl+x stop points, and trim trailing exit sequences
./.scratch/flutter-skills-presentation/prototypes/setup-workspaces.sh postprocess-casts

# 2. Export per-conversation Markdown logs and compare Session Traces from ~/.gemini/**/brain/
./.scratch/flutter-skills-presentation/prototypes/setup-workspaces.sh extract-traces
```
