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
├── parts-tracker-baseline/        # Run 1: No project skills (Global Rule only)
├── parts-tracker-skilled/         # Run 2: Matt Pocock skill chain
└── parts-tracker-comprehension/   # Run 3: Cloned from Baseline + /teach-code
```

Once all three runs are recorded, you copy `~/Demos/flutter-parts-experiment` back into this repo (under `./experiment/` and `./recordings/raw/`) so all post-processing, trace extraction, and slide authoring can happen in-tree.

---

## Step 1: Initialize the Standalone Directory & Workspaces

Run the following in your terminal to create the standalone directory, initialize the `parts-tracker-baseline` and `parts-tracker-skilled` git repositories, and copy the project skills from this repo into `parts-tracker-skilled`:

```bash
export REPO_ROOT="/Users/brett/Documents/GitHub/flutter-skills-presentation"
export EXP_DIR="$HOME/Demos/flutter-parts-experiment"

# 1. Create root and raw recordings folder
mkdir -p "$EXP_DIR/recordings/raw"

# 2. Initialize Run 1 workspace: Baseline Run (zero project skills)
rm -rf "$EXP_DIR/parts-tracker-baseline"
mkdir -p "$EXP_DIR/parts-tracker-baseline"
git -C "$EXP_DIR/parts-tracker-baseline" init -q

# 3. Initialize Run 2 workspace: Skilled Run (Matt Pocock skill pack)
rm -rf "$EXP_DIR/parts-tracker-skilled"
mkdir -p "$EXP_DIR/parts-tracker-skilled/.agents/skills"
git -C "$EXP_DIR/parts-tracker-skilled" init -q

for skill in \
  setup-matt-pocock-skills wayfinder grilling domain-modeling prototype \
  research to-spec to-tickets implement tdd code-review codebase-design \
  diagnosing-bugs triage wizard; do
  cp -R "$REPO_ROOT/.agents/skills/$skill" "$EXP_DIR/parts-tracker-skilled/.agents/skills/$skill"
done
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

### 2.1 Start Recording
```bash
cd "$EXP_DIR/parts-tracker-baseline"
asciinema rec --window-size 120x32 --idle-time-limit 2.0 --overwrite "$EXP_DIR/recordings/raw/01-baseline.cast"
```

### 2.2 Launch `agy` & Run Prompt
Inside the recorded shell:
```bash
agy
```

Paste the initial prompt:
```text
I'd like to build a Flutter app for iOS that enables me to track my electronics parts
```

1. Answer `agy`'s one-at-a-time clarifying questions using the **Canonical Q&A Answers** table above.
2. Let `agy` scaffold the Flutter iOS app and run `flutter analyze` / `flutter test`.
3. Exit `agy` and press `Ctrl+D` (or type `exit`) to finish the `asciinema` recording.

---

## Step 3: Record Run 2 — Skilled Run (`02-skilled.cast`)

> **Tip on Chapter Markers**: While recording `02-skilled.cast`, you can press **`Ctrl+x`** before starting each of the 6 slash-command stages to insert an embedded `"m"` marker in the `.cast` file (or let `mark-cast.py --auto-skilled` detect and label the command boundaries automatically afterwards).
>
> You can either run all 6 stages inside one continuous `asciinema rec` session (starting a fresh `agy` conversation for each stage), or exit `asciinema` between stages and resume with `--append`.

### 3.1 Start Recording
```bash
cd "$EXP_DIR/parts-tracker-skilled"
asciinema rec --window-size 120x32 --idle-time-limit 2.0 --overwrite "$EXP_DIR/recordings/raw/02-skilled.cast"
```

*(If resuming after exiting `asciinema` between stages, replace `--overwrite` with `--append`.)*

### 3.2 Run the 6-Stage Skill Chain

#### Stage 1: `/setup-matt-pocock-skills`
Launch `agy` and enter:
```text
/setup-matt-pocock-skills
```
- Choose **Local Markdown (`.scratch/`)** for the issue tracker.
- Choose **Single context (`GLOSSARY.md` + `docs/adr/`)** for domain modeling.
- Exit `agy` once `AGENTS.md` and `docs/agents/` are written.

#### Stage 2: `/wayfinder` (Chart the Map)
Launch a fresh `agy` session and enter:
```text
/wayfinder I'd like to build a Flutter app for iOS that enables me to track my electronics parts
```
- Answer the grilling and domain-modeling questions using the **Canonical Q&A Answers**.
- Exit `agy` once `GLOSSARY.md`, `.scratch/<app>/map.md`, and the child decision tickets are created.

#### Stage 3: `/wayfinder` (Resolve Decision Tickets)
For each open decision ticket on the map, launch a fresh `agy` session and enter:
```text
/wayfinder
```
- Resolve the claimed ticket using the canonical answers.
- Repeat in a fresh `agy` session until all decision tickets on `.scratch/<app>/map.md` are closed.

#### Stage 4: `/to-spec`
Launch a fresh `agy` session and enter:
```text
/to-spec
```
- Confirm the synthesized specification and testing seams once written to `.scratch/<app>/`.

#### Stage 5: `/to-tickets`
Launch a fresh `agy` session and enter:
```text
/to-tickets
```
- Let `agy` break the specification into vertical-slice implementation tickets.

#### Stage 6: `/implement`
Launch a fresh `agy` session and enter:
```text
/implement
```
- Let `agy` work through the implementation tickets (via `/tdd` and `/code-review`) until the Flutter app passes `flutter analyze` and `flutter test`.
- Exit `agy` and press `Ctrl+D` (or `exit`) to save `02-skilled.cast`.

---

## Step 4: Clone Baseline App & Record Run 3 — Comprehension Run (`03-comprehension.cast`)

### 4.1 Clone the Finished Baseline App and Add `/teach-code`
```bash
rm -rf "$EXP_DIR/parts-tracker-comprehension"
cp -R "$EXP_DIR/parts-tracker-baseline" "$EXP_DIR/parts-tracker-comprehension"
mkdir -p "$EXP_DIR/parts-tracker-comprehension/.agents/skills"

for skill in teach-code teach; do
  cp -R "$REPO_ROOT/.agents/skills/$skill" "$EXP_DIR/parts-tracker-comprehension/.agents/skills/$skill"
done
```

### 4.2 Start Recording
```bash
cd "$EXP_DIR/parts-tracker-comprehension"
asciinema rec --window-size 120x32 --idle-time-limit 2.0 --overwrite "$EXP_DIR/recordings/raw/03-comprehension.cast"
```

### 4.3 Launch `agy` & Run `/teach-code`
Inside the recorded shell:
```bash
agy
```

Paste the prompt:
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

Once your recordings are complete, copy the entire standalone directory back into this repository so the raw `.cast` files and the three generated project directories are inside the workspace:

```bash
export REPO_ROOT="/Users/brett/Documents/GitHub/flutter-skills-presentation"
export EXP_DIR="$HOME/Demos/flutter-parts-experiment"

# Copy raw .cast recordings into repo recordings/raw/
mkdir -p "$REPO_ROOT/recordings/raw" "$REPO_ROOT/recordings/final"
cp -R "$EXP_DIR/recordings/raw/"*.cast "$REPO_ROOT/recordings/raw/"

# Copy the 3 completed workspaces into repo experiments/
mkdir -p "$REPO_ROOT/experiments"
cp -R "$EXP_DIR/parts-tracker-baseline" "$REPO_ROOT/experiments/"
cp -R "$EXP_DIR/parts-tracker-skilled" "$REPO_ROOT/experiments/"
cp -R "$EXP_DIR/parts-tracker-comprehension" "$REPO_ROOT/experiments/"
```

---

## Step 6: Post-Process Casts & Extract Session Traces

After copying the directory back into this repo, either run these two commands yourself or tell the agent in this session (`"Done recording, I've copied the directory back"`) to run them and close Ticket 04:

```bash
cd "$REPO_ROOT"

# 1. Sanitize, inject/label 02-skilled chapter markers, and trim trailing exit sequences
./.scratch/flutter-skills-presentation/prototypes/setup-workspaces.sh postprocess-casts

# 2. Export per-conversation Markdown logs and compare Session Traces from ~/.gemini/**/brain/
./.scratch/flutter-skills-presentation/prototypes/setup-workspaces.sh extract-traces
```
