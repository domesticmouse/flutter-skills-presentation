# Audience, Talk Duration, and Core Thesis

Type: grilling
Label: `wayfinder:grilling`
Status: closed
Assignee: brett

## Question

Who is the target audience for this presentation, how long is the talk slot, and what is the overarching thesis statement that connects the three acts (**Baseline Run** with the **Global Rule**, **Skilled Run** with `/wayfinder`, and **Comprehension Run** with `/teach-code` to dig out of **Comprehension Debt**)?

## Resolution

- **Target Audience**: University students who have been building mobile apps using React. Flutter is conceptually adjacent (declarative component/widget trees and state) yet syntactically and architecturally different enough that an AI-generated Flutter iOS app looks *almost* familiar while quietly creating **Comprehension Debt**.
- **Talk Duration & Format**: 45–50 minute university lecture slot, giving enough breathing room to inspect the `asciinema` **Terminal Casts**, `/agy-brain-explorer` **Session Traces**, and generated `/teach-code` HTML lessons.
- **Core Thesis**: *"Out of the box, an AI coding agent will happily generate a working app in a framework you don't know—and hand you a pile of **Comprehension Debt**. By shaping the agent with rules and Agent Skills (`SKILL.md`), you turn it from an eager code generator into a design partner that interviews you first (`/wayfinder`), and a personal tutor that teaches you the codebase afterwards (`/teach-code`)."*
- **Four-Part Lecture Structure**:
  1. **Act 0 — The Hidden Variable (~7 mins)**: Framing the experiment (building an electronics component catalog iOS app in Flutter from a React background) and revealing the **Global Rule** (`When something is unclear, please ask clarifying questions, one at a time.`)—explaining why this **Baseline Run** behaves differently from a peer running the exact same prompt without that rule.
  2. **Act 1 — The Baseline Run (~10 mins)**: Watching `agy` with only the **Global Rule** active: it asks clarifying questions one by one and builds a working Flutter app, but without explicit domain modelling or architectural maps.
  3. **Act 2 — The Skilled Run (~15 mins)**: Running the same challenge with Matt Pocock's skills (`/wayfinder`, `/grilling`, `/domain-modeling`) installed—comparing **Session Traces** to show how the agent builds a `GLOSSARY.md` and a decision map before writing widgets.
  4. **Act 3 — The Comprehension Run (~13 mins)**: Confronting **Comprehension Debt** as a React developer reading generated Flutter/Dart code, and invoking `/teach-code` to generate tailored HTML lessons, reference sheets, and verification exercises that bridge the React-to-Flutter gap.
