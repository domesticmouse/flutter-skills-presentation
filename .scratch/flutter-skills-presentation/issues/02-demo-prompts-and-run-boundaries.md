# Demo Prompts, Q&A Script, and Run Boundaries

Type: grilling
Label: `wayfinder:grilling`
Status: closed
Assignee: brett

## Question

What exact initial prompts, pre-planned clarifying-question responses, and stopping boundaries will be used across the three `agy` CLI runs on the electronics component catalog Flutter iOS app?

Specifically:
1. What is the exact baseline prompt for the **Baseline Run**, and what canonical answers should be given to `agy`'s one-at-a-time clarifying questions so the run stays focused and reproducible?
2. What is the exact `/wayfinder` prompt and interaction boundary for the **Skilled Run** (e.g., charting the map and `GLOSSARY.md`), and which subset of skills should be installed in that workspace?
3. How should the **Comprehension Run** (`/teach-code`) be invoked against the generated Flutter iOS codebase from the **Baseline Run**—specifically framing the learner as a React mobile developer bridging into Dart/Flutter (per [Audience, Talk Duration, and Core Thesis](./01-audience-and-talk-thesis.md))—and where does that recording stop (e.g., `MISSION.md` + Lesson 0001 compiled to HTML)?

## Resolution

### 1. Baseline Run (No Project Skills; Global Rule Active)
- **Initial Prompt** (deliberately terse so the **Global Rule** drives `agy` to ask clarifying questions one at a time):
  > `"I'd like to build a Flutter app for iOS that enables me to track my electronics parts"`
- **Canonical Answers to `agy`'s Clarifying Questions** (used identically across runs):
  - **Parts / Categories**: Hobbyist/maker electronics parts—resistors, capacitors, ICs/microcontrollers, sensors, LEDs, and breakout boards.
  - **Attributes per Part**: Part name/number, category, quantity on hand, storage location (e.g., drawer/bin label), and a freeform specs/notes field (e.g., `"10kΩ 1%"`, `"3.3V I2C"`).
  - **Core Workflows**: Browse and search parts, filter by category, increment/decrement quantity quickly, and add/edit parts (no barcode scanning, BOM/project tracking, or supplier API integration).
  - **Persistence**: Local on-device storage only (no cloud sync or user accounts), pre-populated with a small set of sample parts on first launch.
  - **UI Style**: Standard clean iOS look (Cupertino or adaptive Material 3).
- **Stopping Boundary & Post-Run Inspection Beat**: Stop recording once `agy` finishes generating the Flutter app and verifying `flutter analyze` / `flutter test`. In the presentation, immediately inspect **what was generated** (pure Flutter source code) vs. **what was NOT generated** (zero **Intent Artifacts**—every domain definition and design decision made during the Q&A exists only in the ephemeral conversation transcript).

### 2. Skilled Run (Full Matt Pocock Skill Chain)
- **Installed Skills**: Full Matt Pocock skill pack (`npx skills add mattpocock/skills`).
- **Multi-Conversation Skill Chain** (captured in a single `asciinema` cast with chapter stop points; see [Asciinema Stop Points and Slidev Chapter Navigation](./05-asciinema-stop-points-and-slidev-navigation.md)):
  1. `/setup-matt-pocock-skills` — Configure `AGENTS.md` and `docs/agents/*` with the local Markdown issue tracker (`.scratch/`) and single-context domain docs (`GLOSSARY.md` + `docs/adr/`).
  2. `/wayfinder` (Chart the map) — Prompt with `"I'd like to build a Flutter app for iOS that enables me to track my electronics parts"`, feeding the exact same canonical answers to build `GLOSSARY.md`, `.scratch/<app>/map.md`, and child decision tickets.
  3. `/wayfinder` (Work through the map) — Run across subsequent conversations until all decision tickets are resolved.
  4. `/to-spec` — Synthesize the resolved map and `GLOSSARY.md` into a complete specification with agreed testing seams.
  5. `/to-tickets` — Break the spec into vertical-slice tracer-bullet tickets.
  6. `/implement` — Implement the tickets via `/tdd` and `/code-review` until the working Flutter iOS app is built and verified alongside its durable **Intent Artifacts**.

### 3. Comprehension Run (`/teach-code` against the Baseline Run App)
- **Target Workspace**: A copy of the **Baseline Run**'s generated Flutter app with `/teach-code` installed in `.agents/skills/` (dramatizing how a React mobile developer digs out of raw **Comprehension Debt** when handed unfamiliar AI-generated Flutter code).
- **Initial Prompt**:
  > `"/teach-code I know React for mobile development, and I just had AI generate this Flutter iOS electronics parts tracker app for me. Help me understand how this codebase works and teach me the Flutter and Dart concepts behind it."`
- **Clarifying Answers to `/teach-code`**:
  - **Prior Background**: Comfortable with React mobile development (components, props, hooks/`useState`, JSX), brand new to Dart and Flutter widget trees/state management.
  - **Mission Goal**: Understand and confidently modify every file in this electronics parts catalog app without relying blindly on the AI.
- **Stopping Boundary**: Stop once `/teach-code` scaffolds `./tutorial/` (`MISSION.md`, `RESOURCES.md`, `NOTES.md`, `reference/GLOSSARY.md`, `build.py`), authors and verifies **Lesson 0001** (and its runnable companion project under `tutorial/apps/0001-...`), and compiles `tutorial/index.html` and `tutorial/lessons/0001-*.html` cleanly via `build.py --check`.
