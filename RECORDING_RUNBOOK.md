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
└── parts_tracker_comprehension/   # Run 3: Cloned from Baseline + npx skills@latest add domesticmouse/skills
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

## Step 4: Clone Baseline App & Record Run 3 — Comprehension Run (`03-comprehension.cast`)

### 4.1 Clone the Finished Baseline App
Before starting the recording, make a clean copy of the finished Baseline Run app:
```bash
cd "$EXP_DIR"
rm -rf "$EXP_DIR/parts_tracker_comprehension"
cp -R "$EXP_DIR/parts_tracker_baseline" "$EXP_DIR/parts_tracker_comprehension"
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

## Step 5: Copy the Resulting Directory Back into This Repo

Once your recordings are complete, copy the standalone directory back into this repository:

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
