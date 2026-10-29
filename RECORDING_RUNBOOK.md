# Operator Recording Runbook: Three-Run Flutter Experiment

This document lists the step-by-step commands, prompts, and canonical Q&A answers to run the three-part experiment in a standalone directory, record the `asciinema` **Terminal Casts**, and copy the resulting directory back into this repository when finished.

---

## Overview of the Standalone Directory Layout

Everything runs inside a single standalone directory outside this repo (`~/Demos/flutter-parts-experiment` by default, or any path you prefer):

```text
~/Demos/flutter-parts-experiment/
├── recordings/
│   └── raw/
│       ├── 01-baseline.cast
│       ├── 02-skilled.cast
│       └── 03-comprehension.cast
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
Confirm `agy` is on `PATH` and authenticated, and verify your **Global Rule** (`When something is unclear, please ask clarifying questions, one at a time.`) is present on this machine so Run 1 (**Baseline Run**) exhibits the expected one-at-a-time questioning behavior:
```bash
which agy
agy --version
find ~/.gemini -maxdepth 3 -iname "*rule*" -o -iname "GEMINI.md" 2>/dev/null
```

### 0.5 Verify `git` and `python3`
`git` is used by `/wayfinder` and `/implement`, and `python3` is used by `/teach-code` (`build.py --check`) to compile the HTML lessons in Run 3:
```bash
git --version
python3 --version
```

---

## Step 1: Create the Standalone Experiment Directory

Run the following in your terminal to create the standalone root directory and raw recordings folder:

```bash
export EXP_DIR="$HOME/Demos/flutter-parts-experiment"
mkdir -p "$EXP_DIR/recordings/raw"
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
```bash
flutter create --platforms=ios parts_tracker_baseline
cd parts_tracker_baseline
agy
```

Paste the initial prompt:
```text
I'd like to build a Flutter app for iOS that enables me to track my electronics parts
```

1. Answer `agy`'s one-at-a-time clarifying questions using the **Canonical Q&A Answers** table above.
2. Let `agy` build the Flutter iOS app and verify `flutter analyze` / `flutter test`.
3. Exit `agy` and press `Ctrl+D` (or type `exit`) to finish the `asciinema` recording.

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

---

## Step 5: Bundle Brain Traces (on Recording Machine) & Copy Back into This Repo

### 5.1 On the Recording Machine: Copy Brain Session Traces into `$EXP_DIR`
Because `agy` stores its **Session Traces** (`transcript.jsonl` / `transcript_full.jsonl`) under `~/.gemini/**/brain/`, run this on the recording machine before transferring `$EXP_DIR` so the session traces travel with the folder:

```bash
export EXP_DIR="$HOME/Demos/flutter-parts-experiment"
mkdir -p "$EXP_DIR/brain-traces"

# Copy any ~/.gemini brain directories modified during the experiment into $EXP_DIR/brain-traces
for bdir in ~/.gemini/*/brain ~/.gemini/brain; do
  if [ -d "$bdir" ]; then
    parent_name="$(basename "$(dirname "$bdir")")"
    mkdir -p "$EXP_DIR/brain-traces/$parent_name"
    cp -R "$bdir" "$EXP_DIR/brain-traces/$parent_name/"
  fi
done
```

### 5.2 On This Machine: Copy the Resulting Directory into This Repo
Once you transfer `$EXP_DIR` back to this machine, copy its contents into this repository:

```bash
export REPO_ROOT="/Users/brett/Documents/GitHub/flutter-skills-presentation"
export EXP_DIR="$HOME/Demos/flutter-parts-experiment"

# Copy raw .cast recordings into repo recordings/raw/
mkdir -p "$REPO_ROOT/recordings/raw" "$REPO_ROOT/recordings/final"
cp -R "$EXP_DIR/recordings/raw/"*.cast "$REPO_ROOT/recordings/raw/"

# Copy the completed project directories into repo experiments/
mkdir -p "$REPO_ROOT/experiments"
cp -R "$EXP_DIR/parts_tracker_baseline" "$REPO_ROOT/experiments/"
cp -R "$EXP_DIR/parts_tracker_skilled" "$REPO_ROOT/experiments/"
cp -R "$EXP_DIR/parts_tracker_comprehension" "$REPO_ROOT/experiments/"

# If brain-traces were bundled from another machine, copy them into artifacts/brain-traces/
if [ -d "$EXP_DIR/brain-traces" ]; then
  mkdir -p "$REPO_ROOT/artifacts"
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
