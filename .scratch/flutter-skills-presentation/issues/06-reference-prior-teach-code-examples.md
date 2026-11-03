# Reference Prior Training Material Examples (learn-egui and BufferedMult-SKiDL)

Type: grilling
Label: `wayfinder:grilling`
Status: closed
Assignee: brett

## Question

How and where in the presentation narrative and Slidev deck specification (particularly in **Act 3 — The Comprehension Run**) should we reference and showcase the following published training materials created in the same fashion with `/teach-code` as the React-to-Flutter training material constructed during this presentation?

- https://domesticmouse.github.io/learn-egui/
- https://domesticmouse.github.io/BufferedMult-SKiDL/

Specifically:
1. Where in the Act 3 narrative beat should these two live examples be introduced (e.g., after the **Comprehension Run** terminal cast stops at Lesson 0001, to show what a complete multi-lesson `/teach-code` site looks like in production and across domains like Rust GUI and electronics CAD)?
2. How should they be displayed on the slides (e.g., side-by-side visual callout cards, live links/QR codes for students to browse, or screenshots of their lesson indices and reference sheets)?

## Resolution

1. **Placement in Narrative Arc**: Introduce both published `/teach-code` sites in the **final synthesis / wrap-up at the end of Act 3** as take-home further reading links for students, showing what a complete multi-lesson `/teach-code` curriculum looks like beyond the Lesson 0001 React-to-Flutter bootstrap built live during the **Comprehension Run**.
2. **Slide Presentation (`layout: default`)**: Feature both courses on a **`Take-Home Links & Further Reading`** closing slide alongside the skill repositories (`mattpocock/skills` and `domesticmouse/skills`), with clickable URLs and a concise domain description for each (no extra browser screenshots required):
   - **https://domesticmouse.github.io/learn-egui/** — Multi-lesson `/teach-code` course teaching Rust immediate-mode GUI development with `egui`.
   - **https://domesticmouse.github.io/BufferedMult-SKiDL/** — Multi-lesson `/teach-code` course teaching Python-driven electronics schematic CAD and Eurorack hardware design with SKiDL.
