# Recording Runbook and Workspace Setup Script

Type: prototype
Label: `wayfinder:prototype`
Status: open
Blocked by: 02, 05

## Question

Once the prompts and boundaries in [Demo Prompts, Q&A Script, and Run Boundaries](./02-demo-prompts-and-run-boundaries.md) are settled, what concrete setup script and step-by-step operator runbook should walk the human through:
1. Initializing clean, isolated directories for the **Baseline Run** (no project skills) and the **Skilled Run** / **Comprehension Run** (with Matt Pocock's skills and `/teach-code` installed),
2. Capturing each `asciinema` **Terminal Cast** with consistent terminal dimensions and idle-time limits, and sanitizing/trimming them via `/asciinema`, and
3. Extracting and comparing the **Session Traces** from `~/.gemini/**/brain/` using `/agy-brain-explorer`?
