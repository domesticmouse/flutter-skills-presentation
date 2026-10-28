# Asciinema Stop Points and Slidev Chapter Navigation

Type: prototype
Label: `wayfinder:prototype`
Status: open

## Question

How should stop points (chapter markers) be captured in an `asciinema` `.cast` recording—especially for the single-cast **Skilled Run** spanning `/setup-matt-pocock-skills`, `/wayfinder`, `/to-spec`, `/to-tickets`, and `/implement`—and how should the Slidev deck (`cast-full.vue` and `AsciinemaPlayer.vue`) let the presenter pause at and step through those stop points live on stage without conflicting with Slidev's slide-advance keyboard shortcuts?

Specifically:
1. During recording or post-processing, should stop points be inserted via `Ctrl+x` (`"m"` marker events in the `.cast` stream), via a wrapper command/script between `agy` CLI invocations, or via `markers: [[timestamp, label], ...]` in slide frontmatter?
2. How should `cast-full.vue` and `AsciinemaPlayer.vue` expose `pauseOnMarkers`, `markers`, `startAt`, and clickable chapter-pill buttons (or keyboard bindings) so the presenter can jump to and pause at each step of the Matt Pocock skill flow inside a single `.cast`?
