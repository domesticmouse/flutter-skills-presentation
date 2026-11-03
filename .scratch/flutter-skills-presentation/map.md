# Flutter Skills Presentation Map

Label: `wayfinder:map`

## Destination

A complete **Presentation Script & Slidev Deck Specification** demonstrating the value of Agent Skills in Flutter iOS app development—backed by hand-recorded `asciinema` **Terminal Casts** and `/agy-brain-explorer` **Session Traces** across three runs:
1. **Baseline Run**: Building a Flutter iOS electronics component catalog app with no project skills (highlighting the effect of the user's **Global Rule**, and contrasting the generated Flutter code against the missing **Intent Artifacts** trapped in chat history).
2. **Skilled Run**: Building the same app across the full Matt Pocock skill chain (`/setup-matt-pocock-skills` → `/wayfinder` → `/to-spec` → `/to-tickets` → `/implement`) to produce both a working Flutter app and repo-committed **Intent Artifacts** (`GLOSSARY.md`, `map.md`, decision tickets, spec).
3. **Comprehension Run**: Using `/teach-code` against the **Skilled Run**'s generated codebase to dig out of **Comprehension Debt** and build a React-to-Flutter pathway to understanding.

## Notes

- **Domain & Glossary**: Consult [GLOSSARY.md](../../GLOSSARY.md) in every session and maintain terms via `/domain-modeling`.
- **Mandatory Slide Requirement**: Explicitly include a slide showing the user's **Global Rule** in `$HOME/.gemini/config/AGENTS.md` (`You are a helpful assistant. When something is unclear, please ask clarifying questions, one at a time.`) and explaining how it alters the **Baseline Run** compared to another developer running the same Flutter prompt without that rule.
- **Skills to Consult**:
  - Planning & Interviewing: `/wayfinder`, `/grilling`, `/domain-modeling`, `/prototype`, `/wizard`
  - Recording, Cast Players & Trace Extraction: `/asciinema`, `/cast-player-html`, `/agy-brain-explorer`, `/ios-simulator-screenshot`, `/crop-image`
  - Narrative & Deck Authoring: `/writing-fragments`, `/writing-beats`, `/writing-shape`, `/bjm-voice`, `/slidev-deck`
- **Issue Tracker**: Local Markdown (`.scratch/flutter-skills-presentation/`).

## Decisions so far

<!-- the index: one line per closed ticket, enough to judge relevance, then zoom the link for the detail the ticket holds -->

- [Audience, Talk Duration, and Core Thesis](./issues/01-audience-and-talk-thesis.md): 45–50 min university lecture for React mobile dev students; thesis frames rules and Agent Skills as turning `agy` from a **Comprehension Debt** generator into a design partner (`/wayfinder`) and React-to-Flutter tutor (`/teach-code`) across a 4-part arc (Act 0 Hidden Variable + Acts 1–3).
- [Demo Prompts, Q&A Script, and Run Boundaries](./issues/02-demo-prompts-and-run-boundaries.md): Fixed terse initial prompt (`"I'd like to build a Flutter app for iOS that enables me to track my electronics parts"`) + canonical Q&A script; **Baseline Run** builds app (revealing missing **Intent Artifacts**); **Skilled Run** walks full chain (`npx skills@latest add mattpocock/skills` → `/wayfinder` → `/to-spec` → `/to-tickets` → `/implement`) in a single cast; **Comprehension Run** runs `/teach-code` on the **Skilled Run** app (`npx skills@latest add domesticmouse/skills`) through Lesson 0001 HTML build.
- [Asciinema Stop Points and Slidev Chapter Navigation](./issues/05-asciinema-stop-points-and-slidev-navigation.md): Hybrid embedded `.cast` `"m"` markers (`Ctrl+x` or `mark-cast.py --auto-baseline` / `--auto-skilled` / `--auto-comprehension` + `--tighten-pastes`) normalized from `asciicast v3` → `v2` in memory by `AsciinemaPlayer.vue` and [06-baseline-cast-player.html](./prototypes/06-baseline-cast-player.html); Variant A header chapter pills (`0. Start`, numbered stop points `1..15`, and `→ End`) in `cast-full.vue` with `pauseOnMarkers: true`, adaptive per-segment playback speeds (`>= 2x`, `<= 30s` per segment, e.g. `2x`/`3x`/`5x`/`18x`/`29x`) with live `⚡ Speed: Nx` HUD indicators, and capture-phase `[` / `]` / `p` stage hotkeys (`stopPropagation`).
- [Recording Runbook and Workspace Setup Script](./issues/03-recording-runbook-and-setup-script.md): Step-by-step operator runbook ([RECORDING_RUNBOOK.md](../../RECORDING_RUNBOOK.md) & [03-recording-runbook.html](./prototypes/03-recording-runbook.html)) backed by `setup-workspaces.sh` (`~/Demos/flutter-parts-experiment/parts_tracker_{baseline,skilled,comprehension}`, `120x32` / `2.0s` idle-cap `asciinema rec`, `process-run <cast> <proj>` running `sanitize-cast.py` + `mark-cast.py --auto-* --tighten-pastes` + `trim-cast.py --hold 3.0`, and `agy-brain-explorer.py` multi-take cleanup & trace export).
- [Capture and Process Baseline Run iOS App Screenshots](./issues/07-baseline-ios-screenshots.md): All 6 `1206x2622 px` iOS Simulator screenshots (`01-parts-inventory.png` through `06-import-export-sheet.png`) captured via `xcrun simctl` and verified in `artifacts/screenshots/parts_tracker_baseline/`.

## Open Issues

- [Capture Terminal Casts and Extract Session Traces](./issues/04-capture-casts-and-session-traces.md): **Run 1 (`parts_tracker_baseline`) complete & verified** (`01-baseline.cast` with 15 stop points + tightened paste delays, `06-baseline-cast-player.html` synced, 2 session traces exported, and 6 iOS screenshots captured); **Run 2 (`parts_tracker_skilled`)** and **Run 3 (`parts_tracker_comprehension`)** pending recording.
- [Capture and Process Skilled Run iOS App Screenshots](./issues/08-skilled-ios-screenshots.md): **Phase 1 complete** (`OptionA.png`, `OptionB.png`, and `OptionC.png` `1206x2622 px` `/wayfinder` scoping prototype screenshots staged and verified in `artifacts/screenshots/parts_tracker_skilled/`); **Phase 2 pending** final app build screenshots after `/implement`.
- [Reference Prior Training Material Examples (learn-egui and BufferedMult-SKiDL)](./issues/06-reference-prior-teach-code-examples.md): Deciding where and how in Act 3 to showcase the published `learn-egui` and `BufferedMult-SKiDL` `/teach-code` sites.

## Not yet specified

- **Trace & Cast Curation**: Once the **Terminal Casts** and **Session Traces** are captured, deciding which specific turns, tool-call diffs (`/agy-brain-explorer compare`), and generated artifacts (`GLOSSARY.md`, `map.md`, and `/teach-code`'s `tutorial/` HTML lessons/reference sheets) best illustrate the behavioral shift on slides.
- **Presentation Narrative Script**: Shaping the spoken narrative and beat-by-beat transitions across the three acts (**Baseline Run** + **Global Rule** caveat → **Skilled Run** with `/wayfinder` → **Comprehension Run** with `/teach-code` to overcome **Comprehension Debt**) using the writing skills and `/bjm-voice`.
- **Slidev Deck Specification**: Defining the act files (`slides/acts/*.md`), slide layouts (`cast-full`, `skill-breakdown`, `hardware-callout`, `default`), playback speeds, and visual callouts ready to hand off to `/slidev-deck`.

## Out of scope

- **Executing the Slidev Build & GitHub Pages Deployment**: Scaffolding `slides/` and authoring the final Vue/Markdown deck happens after this map's specification and script are complete.
