# Flutter Skills Presentation

A technical presentation and live-recorded experiment demonstrating how Agent Skills reshape AI-assisted software development in Google Antigravity (`agy` CLI), contrasted through building a Flutter iOS electronics component catalog app.

## Language

**Baseline Run**:
The first recorded `agy` CLI session building the electronics component catalog Flutter iOS app with only the Global Rule active and no project-level Agent Skills installed.
_Avoid_: Vanilla run, unassisted run, first app

**Skilled Run**:
The second recorded `agy` CLI session designing the electronics component catalog Flutter iOS app with Matt Pocock's skills installed, starting with `/wayfinder`.
_Avoid_: Enhanced run, second app, v2 run

**Comprehension Run**:
The third `agy` CLI session invoking `/teach-code` to generate an interactive learning pathway (HTML lessons, reference sheets, and verification exercises) that digs a developer out of Comprehension Debt on an AI-generated codebase.
_Avoid_: Teaching run, tutorial run, third app

**Comprehension Debt**:
The form of technical debt created when an AI agent generates a working codebase that the developer no longer understands well enough to maintain or extend confidently.
_Avoid_: AI technical debt, code unfamiliarity

**Global Rule**:
The user-level instruction (`You are a helpful assistant. When something is unclear, please ask clarifying questions, one at a time.`) active across all `agy` sessions, which alters baseline agent behavior even when no project skills are present.
_Avoid_: System prompt, global prompt, custom instructions

**Session Trace**:
The structured record of prompts, model reasoning, and tool invocations stored in `~/.gemini/**/brain/` and extracted or compared using `/agy-brain-explorer`.
_Avoid_: Chat log, raw transcript

**Terminal Cast**:
A `.cast` terminal session recording captured with `asciinema` and embedded interactively into the slide deck.
_Avoid_: Screen recording, video clip
