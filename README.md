# Flutter Skills Presentation

A technical presentation and live-recorded experiment demonstrating how Agent Skills (`SKILL.md`) reshape AI-assisted software development in Google Antigravity (`agy` CLI), contrasted through building a Flutter iOS electronics component catalog app.

> **Core Thesis**: *"Out of the box, an AI coding agent will happily generate a working app in a framework you don't know—and hand you a pile of **Comprehension Debt**. By shaping the agent with rules and Agent Skills (`SKILL.md`), you turn it from an eager code generator into a design partner that interviews you first (`/wayfinder`), and a personal tutor that teaches you the codebase afterwards (`/teach-code`)."*

---

## The Three-Run Experiment

Designed for a 45–50 minute university lecture for mobile development students coming from React, the presentation compares three recorded `agy` CLI workflows initiated from the same prompt:

> `"I'd like to build a Flutter app for iOS that enables me to track my electronics parts"`

1. **Act 0 — The Hidden Variable**: Exposes the user-level **Global Rule** in `$HOME/.gemini/config/AGENTS.md` (`You are a helpful assistant. When something is unclear, please ask clarifying questions, one at a time.`) and explains how it alters baseline agent behavior before any project skills are introduced.
2. **Act 1 — Baseline Run**: Building the electronics component catalog app with only the **Global Rule** active and no project-level Agent Skills installed. Produces a working Flutter app, but leaves domain vocabulary and architectural decisions trapped in ephemeral chat history rather than durable **Intent Artifacts**.
3. **Act 2 — Skilled Run**: Building the same app across the Matt Pocock skill chain (`/setup-matt-pocock-skills` → `/wayfinder` → `/to-spec` → `/to-tickets` → `/implement`), producing both a working Flutter app and repo-committed **Intent Artifacts** (`GLOSSARY.md`, `map.md`, resolved decision tickets, and spec).
4. **Act 3 — Comprehension Run**: Running `/teach-code` against the **Skilled Run** codebase to dig out of **Comprehension Debt** via generated HTML lessons, printable reference sheets, and verification exercises tailored to bridge React concepts to Flutter/Dart.

---

## Repository Structure

| Path | Description |
| :--- | :--- |
| [`GLOSSARY.md`](./GLOSSARY.md) | Canonical domain terminology (**Baseline Run**, **Skilled Run**, **Comprehension Run**, **Intent Artifacts**, **Comprehension Debt**, **Global Rule**, **Session Trace**, **Terminal Cast**). |
| [`.scratch/flutter-skills-presentation/map.md`](./.scratch/flutter-skills-presentation/map.md) | Wayfinder map tracking the presentation specification, resolved decisions, and remaining open questions. |
| [`.scratch/flutter-skills-presentation/issues/`](./.scratch/flutter-skills-presentation/issues/) | Resolved and open Wayfinder tickets covering talk thesis, canonical Q&A script, asciinema stop-points, and operator runbook. |
| [`.scratch/flutter-skills-presentation/prototypes/`](./.scratch/flutter-skills-presentation/prototypes/) | Interactive HTML prototypes ([`03-recording-runbook.html`](./.scratch/flutter-skills-presentation/prototypes/03-recording-runbook.html), [`05-stop-points.html`](./.scratch/flutter-skills-presentation/prototypes/05-stop-points.html)) and recording helpers ([`setup-workspaces.sh`](./.scratch/flutter-skills-presentation/prototypes/setup-workspaces.sh), [`mark-cast.py`](./.scratch/flutter-skills-presentation/prototypes/mark-cast.py)). |
| [`.agents/skills/`](./.agents/skills/) | Installed project Agent Skills for planning (`/wayfinder`, `/grilling`, `/domain-modeling`, `/prototype`), recording & trace analysis (`/asciinema`, `/agy-brain-explorer`), teaching (`/teach-code`), and deck authoring (`/bjm-voice`, `/slidev-deck`). |
| [`skills-lock.json`](./skills-lock.json) | Lockfile pinning installed Agent Skills. |

---

## Reproducing the Demo Workspaces & Recordings

The operator runbook and workspace setup script initialize isolated demo directories under `~/Demos/flutter-parts-experiment/` (`parts-tracker-baseline`, `parts-tracker-skilled`, and `parts-tracker-comprehension`), post-process `asciinema` **Terminal Casts**, and extract `/agy-brain-explorer` **Session Traces**.

1. **Open the Interactive Runbook**:
   Open [`.scratch/flutter-skills-presentation/prototypes/03-recording-runbook.html`](./.scratch/flutter-skills-presentation/prototypes/03-recording-runbook.html) in a browser for the step-by-step operator checklist and copyable prompts.

2. **Initialize the Baseline & Skilled Workspaces**:
   ```bash
   ./.scratch/flutter-skills-presentation/prototypes/setup-workspaces.sh init
   ```

3. **Clone the Baseline App for the Comprehension Run** *(after completing the Baseline Run)*:
   ```bash
   ./.scratch/flutter-skills-presentation/prototypes/setup-workspaces.sh clone-comprehension
   ```

4. **Sanitize, Mark, and Trim Terminal Casts**:
   ```bash
   ./.scratch/flutter-skills-presentation/prototypes/setup-workspaces.sh postprocess-casts
   ```

5. **Extract and Compare Session Traces**:
   ```bash
   ./.scratch/flutter-skills-presentation/prototypes/setup-workspaces.sh extract-traces
   ```

---

## License

Licensed under the [Apache License, Version 2.0](./LICENSE).

---

*This is not an officially supported Google product.*
