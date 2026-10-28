# Flutter Skills Presentation Map

Label: `wayfinder:map`

## Destination

A complete **Presentation Script & Slidev Deck Specification** demonstrating the value of Agent Skills in Flutter iOS app development—backed by hand-recorded `asciinema` **Terminal Casts** and `/agy-brain-explorer` **Session Traces** across three runs:
1. **Baseline Run**: Building a Flutter iOS electronics component catalog app with no project skills (highlighting the effect of the user's **Global Rule**).
2. **Skilled Run**: Designing the same app in the presence of Matt Pocock's skills using `/wayfinder` (`grilling` + `domain-modeling`).
3. **Comprehension Run**: Using `/teach-code` against the generated codebase to dig out of **Comprehension Debt** and build a pathway to understanding.

## Notes

- **Domain & Glossary**: Consult [GLOSSARY.md](../../GLOSSARY.md) in every session and maintain terms via `/domain-modeling`.
- **Mandatory Slide Requirement**: Explicitly include a slide showing the user's **Global Rule** (`You are a helpful assistant. When something is unclear, please ask clarifying questions, one at a time.`) and explaining how it alters the **Baseline Run** compared to another developer running the same Flutter prompt without that rule.
- **Skills to Consult**:
  - Planning & Interviewing: `/wayfinder`, `/grilling`, `/domain-modeling`, `/prototype`, `/wizard`
  - Recording & Trace Extraction: `/asciinema`, `/agy-brain-explorer`, `/crop-image`
  - Narrative & Deck Authoring: `/writing-fragments`, `/writing-beats`, `/writing-shape`, `/bjm-voice`, `/slidev-deck`
- **Issue Tracker**: Local Markdown (`.scratch/flutter-skills-presentation/`).

## Decisions so far

<!-- the index: one line per closed ticket, enough to judge relevance, then zoom the link for the detail the ticket holds -->

## Not yet specified

- **Trace & Cast Curation**: Once the **Terminal Casts** and **Session Traces** are captured, deciding which specific turns, tool-call diffs (`/agy-brain-explorer compare`), and generated artifacts (`GLOSSARY.md`, `map.md`, and `/teach-code`'s `tutorial/` HTML lessons/reference sheets) best illustrate the behavioral shift on slides.
- **Presentation Narrative Script**: Shaping the spoken narrative and beat-by-beat transitions across the three acts (**Baseline Run** + **Global Rule** caveat → **Skilled Run** with `/wayfinder` → **Comprehension Run** with `/teach-code` to overcome **Comprehension Debt**) using the writing skills and `/bjm-voice`.
- **Slidev Deck Specification**: Defining the act files (`slides/acts/*.md`), slide layouts (`cast-full`, `skill-breakdown`, `hardware-callout`, `default`), playback speeds, and visual callouts ready to hand off to `/slidev-deck`.

## Out of scope

- **Executing the Slidev Build & GitHub Pages Deployment**: Scaffolding `slides/` and authoring the final Vue/Markdown deck happens after this map's specification and script are complete.
