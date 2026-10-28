# Demo Prompts, Q&A Script, and Run Boundaries

Type: grilling
Label: `wayfinder:grilling`
Status: open

## Question

What exact initial prompts, pre-planned clarifying-question responses, and stopping boundaries will be used across the three `agy` CLI runs on the electronics component catalog Flutter iOS app?

Specifically:
1. What is the exact baseline prompt for the **Baseline Run**, and what canonical answers should be given to `agy`'s one-at-a-time clarifying questions so the run stays focused and reproducible?
2. What is the exact `/wayfinder` prompt and interaction boundary for the **Skilled Run** (e.g., charting the map and `GLOSSARY.md`), and which subset of skills should be installed in that workspace?
3. How should the **Comprehension Run** (`/teach-code`) be invoked against the generated Flutter iOS codebase from the **Baseline Run**—specifically framing the learner as a React mobile developer bridging into Dart/Flutter (per [Audience, Talk Duration, and Core Thesis](./01-audience-and-talk-thesis.md))—and where does that recording stop (e.g., `MISSION.md` + Lesson 0001 compiled to HTML)?
