# Shaping AI Coding Agents with Skills

**Intro to Google Antigravity (`agy`) & Agent Skills (`SKILL.md`): From Vibe-Coding to Design Partner and Personal Tutor**

A 45-minute hackathon presentation and live-recorded experiment demonstrating how always-on Rules (`AGENTS.md`) and on-demand Agent Skills (`SKILL.md`) reshape AI-assisted software development in Google Antigravity (`agy` CLI & IDE)—illustrated by having a React + TypeScript developer ship a native iOS electronics component catalog app in an unfamiliar stack (Flutter + Dart).

> **Core Thesis**: *"Out of the box, an AI coding agent will happily generate a working app in a stack you don't know—and hand you a pile of **Comprehension Debt**. By shaping `agy` (or any agent harness) with `AGENTS.md` and Agent Skills (`SKILL.md`), you turn an eager code generator into a **Design Partner** that interviews you and commits durable **Intent Artifacts** first (`/wayfinder`), and a **Personal Tutor** that teaches you the codebase afterwards (`/teach-code`)."*

---

## Live Presentation & Hosted Tutorial (GitHub Pages)

- **Slidev Presentation Deck**: [`https://domesticmouse.github.io/flutter-skills-presentation/`](https://domesticmouse.github.io/flutter-skills-presentation/)
- **Interactive React + TypeScript → Flutter + Dart Course (`/teach-code` Output)**: [`https://domesticmouse.github.io/flutter-skills-presentation/tutorial/index.html`](https://domesticmouse.github.io/flutter-skills-presentation/tutorial/index.html)
  - [Lesson 0001: Flutter Bootstrap, `ProviderScope` & Dark Workbench Shell](https://domesticmouse.github.io/flutter-skills-presentation/tutorial/lessons/0001-flutter-bootstrap-and-provider-scope.html)
  - [Lesson 0002: Immutable Domain Models with Freezed & JSON Serialization](https://domesticmouse.github.io/flutter-skills-presentation/tutorial/lessons/0002-immutable-domain-models-with-freezed.html)
  - [Lesson 0003: Persistence Seam & Atomic Local File Storage](https://domesticmouse.github.io/flutter-skills-presentation/tutorial/lessons/0003-persistence-seam-and-atomic-file-storage.html)
  - [Lesson 0004: Reactive Catalog State with Riverpod `AsyncNotifier`](https://domesticmouse.github.io/flutter-skills-presentation/tutorial/lessons/0004-reactive-catalog-state-with-riverpod.html)
  - [Lesson 0005: Engineering Unit Search Engine & Derived Filter Providers](https://domesticmouse.github.io/flutter-skills-presentation/tutorial/lessons/0005-engineering-unit-search-and-filter-providers.html)
  - [Reference Sheet: React & TypeScript → Flutter & Dart Cheat Sheet](https://domesticmouse.github.io/flutter-skills-presentation/tutorial/reference/react-to-flutter-cheatsheet.html)
  - [Reference Sheet: Glossary of Parts Tracker & Flutter Terms](https://domesticmouse.github.io/flutter-skills-presentation/tutorial/reference/glossary.html)
  - [Reference Sheet: Verification & Widget Testing Reference](https://domesticmouse.github.io/flutter-skills-presentation/tutorial/reference/verification-and-testing.html)
- **Additional `/teach-code` Courses Featured in the Talk**:
  - [Learn `egui` — Rust Immediate-Mode GUI Course](https://domesticmouse.github.io/learn-egui/)
  - [BufferedMult-SKiDL — Python Electronics Schematic CAD & Eurorack Hardware Course](https://domesticmouse.github.io/BufferedMult-SKiDL/)

---

## Agent Skill Repositories Used

Installable into `.agents/skills/` across Google Antigravity (`agy`), Claude Code, Cursor, and other harnesses via `npx skills`:

```bash
# Act 2 — Design Partner & Engineering Workflow Skills (/wayfinder, /grilling, /domain-modeling, /research, /prototype, /tdd, /code-review, /to-spec, /to-tickets, /implement)
npx skills@latest add mattpocock/skills

# Act 3 & Presentation Tooling — Personal Tutor & Reproducibility Skills (/teach-code, /slidev-deck, /asciinema, /cast-player-html, /agy-brain-explorer, /ios-simulator-screenshot, /crop-image)
npx skills@latest add domesticmouse/skills
```

- [`github.com/mattpocock/skills`](https://github.com/mattpocock/skills)
- [`github.com/domesticmouse/skills`](https://github.com/domesticmouse/skills)

---

## The Controlled Three-Run Experiment

Designed as a 45-minute introduction to Google Antigravity and Agent Skills, the presentation compares three live-recorded `agy` CLI runs initiated from the exact same prompt:

> `"I'd like to build a Flutter app for iOS that enables me to track my electronics parts"`

1. **Act 0 — Opening & The Hidden Variable** ([`slides/acts/01-hidden-variable.md`](./slides/acts/01-hidden-variable.md)): Introduces the Vibe-Coding Trap (**Comprehension Debt**), Google Antigravity (`agy`), the `AGENTS.md` vs. `SKILL.md` customization stack, the electronics parts tracker mission, and exposes the user-level **Global Rule** in `$HOME/.gemini/config/AGENTS.md` (`You are a helpful assistant. When something is unclear, please ask clarifying questions, one at a time.`).
2. **Act 1 — Baseline Run** ([`slides/acts/02-baseline-run.md`](./slides/acts/02-baseline-run.md)): Building the electronics component catalog app with only the **Global Rule** active and no project-level Agent Skills installed. Produces a working Flutter app, but leaves domain vocabulary and architectural decisions trapped in ephemeral chat history rather than durable **Intent Artifacts** when `/clear` is run.
3. **Act 2 — Skilled Run** ([`slides/acts/03-skilled-run.md`](./slides/acts/03-skilled-run.md)): Installing [`mattpocock/skills`](https://github.com/mattpocock/skills) (`npx skills@latest add mattpocock/skills`) and walking `/wayfinder` → `/to-spec` → `/to-tickets` → `/implement`, producing both a working Flutter app and repo-committed **Intent Artifacts** (`GLOSSARY.md`, `map.md`, resolved decision tickets, simulator prototypes, and `spec.md`) that survive `/clear`.
4. **Act 3 — Comprehension Run** ([`slides/acts/04-comprehension-run.md`](./slides/acts/04-comprehension-run.md)): Installing [`domesticmouse/skills`](https://github.com/domesticmouse/skills) (`npx skills@latest add domesticmouse/skills`) and running `/teach-code` against the **Skilled Run** codebase to pay down **Comprehension Debt** via generated HTML lessons, printable reference sheets, and runnable companion exercises in [`experiments/parts_tracker_comprehension/tutorial/`](./experiments/parts_tracker_comprehension/tutorial/) tailored to bridge React + TypeScript concepts to Flutter + Dart 3.

---

## Running & Building the Slidev Deck Locally

```bash
# Install dependencies in slides/
npm --prefix slides install

# Start the local Slidev dev server on http://localhost:3030/
# (predev automatically syncs tutorial/ -> slides/public/tutorial/ and recordings/final/*.cast -> slides/public/casts/)
.agents/skills/slidev-deck/scripts/slides-server.sh start

# Check dev server status
.agents/skills/slidev-deck/scripts/slides-server.sh status

# Build static production site (slides/dist/, including synced casts and /tutorial/)
npm --prefix slides run build
```

---

## Repository Structure

| Path | Description |
| :--- | :--- |
| [`slides/`](./slides/) | Slidev v53 presentation deck (`slides.md`, modular `acts/*.md`, `AsciinemaPlayer.vue`, custom layouts, synced `.cast` recordings, iOS screenshots, and synced `/tutorial/` portal). |
| [`.github/workflows/deploy-slides.yml`](./.github/workflows/deploy-slides.yml) | GitHub Actions workflow deploying `slides/dist` (including `/tutorial/` and `/casts/`) to GitHub Pages when `slides/**`, `experiments/parts_tracker_comprehension/tutorial/**`, or `recordings/final/*.cast` change on `main`. |
| [`experiments/`](./experiments/) | Completed Flutter iOS project workspaces for all three runs (`parts_tracker_baseline`, `parts_tracker_skilled`, and `parts_tracker_comprehension`, including [`tutorial/`](./experiments/parts_tracker_comprehension/tutorial/)). |
| [`recordings/`](./recordings/) | Captured raw (`recordings/raw/`) and sanitized/marked/trimmed (`recordings/final/`) `.cast` **Terminal Casts** (`01-baseline.cast`, `02-skilled.cast`, `03-comprehension.cast`). |
| [`artifacts/traces/`](./artifacts/traces/) | Exported per-session Antigravity Markdown **Session Traces** across all three runs (`parts_tracker_baseline`, `parts_tracker_skilled`, `parts_tracker_comprehension`). |
| [`artifacts/screenshots/`](./artifacts/screenshots/) | Captured `1206×2622 px` iOS Simulator screenshots for `parts_tracker_baseline` (6 views) and `parts_tracker_skilled` (3 `/prototype` options + 7 final views). |
| [`GLOSSARY.md`](./GLOSSARY.md) | Canonical domain terminology (**Baseline Run**, **Skilled Run**, **Comprehension Run**, **Intent Artifacts**, **Comprehension Debt**, **Global Rule**, **Session Trace**, **Terminal Cast**). |
| [`RECORDING_RUNBOOK.md`](./RECORDING_RUNBOOK.md) | Step-by-step operator runbook for recording the three `asciinema` **Terminal Casts**, processing stop points, and exporting **Session Traces**. |
| [`.scratch/flutter-skills-presentation/`](./.scratch/flutter-skills-presentation/) | Wayfinder `map.md`, resolved decision tickets (`issues/01`–`08`), and standalone HTML cast-player prototypes (`06-baseline-cast-player.html`, `07-skilled-cast-player.html`, `08-comprehension-cast-player.html`). |
| [`.agents/skills/`](./.agents/skills/) | Installed project Agent Skills from `mattpocock/skills` and `domesticmouse/skills` (`/wayfinder`, `/grilling`, `/domain-modeling`, `/prototype`, `/tdd`, `/code-review`, `/teach-code`, `/slidev-deck`, `/asciinema`, `/cast-player-html`, `/agy-brain-explorer`, `/ios-simulator-screenshot`, `/crop-image`, `/bjm-voice`). |

---

## License

Licensed under the [Apache License, Version 2.0](./LICENSE).

---

*This is not an officially supported Google product.*
