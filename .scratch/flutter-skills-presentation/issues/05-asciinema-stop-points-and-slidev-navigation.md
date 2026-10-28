# Asciinema Stop Points and Slidev Chapter Navigation

Type: prototype
Label: `wayfinder:prototype`
Status: closed
Assignee: brett

## Question

How should stop points (chapter markers) be captured in an `asciinema` `.cast` recording—especially for the single-cast **Skilled Run** spanning `/setup-matt-pocock-skills`, `/wayfinder`, `/to-spec`, `/to-tickets`, and `/implement`—and how should the Slidev deck (`cast-full.vue` and `AsciinemaPlayer.vue`) let the presenter pause at and step through those stop points live on stage without conflicting with Slidev's slide-advance keyboard shortcuts?

Specifically:
1. During recording or post-processing, should stop points be inserted via `Ctrl+x` (`"m"` marker events in the `.cast` stream), via a wrapper command/script between `agy` CLI invocations, or via `markers: [[timestamp, label], ...]` in slide frontmatter?
2. How should `cast-full.vue` and `AsciinemaPlayer.vue` expose `pauseOnMarkers`, `markers`, `startAt`, and clickable chapter-pill buttons (or keyboard bindings) so the presenter can jump to and pause at each step of the Matt Pocock skill flow inside a single `.cast`?

## Resolution

Validated via interactive prototype: [05-stop-points.html](../prototypes/05-stop-points.html).

### 1. Hybrid Embedded `.cast` `"m"` Markers + Post-Process Labeler (`mark-cast.py`)
- **Recording & Post-Processing**: Stop points are stored directly inside the `.cast` file as native asciicast `"m"` marker events (`[dt, "m", "1. /setup-matt-pocock-skills"]`, etc.). During `asciinema rec`, the operator can press `Ctrl+x` before each new `agy` invocation or run a post-processing script (`mark-cast.py` in `/asciinema`) that detects `agy` command boundaries (or labels existing unlabeled `"m"` events) and writes canonical chapter labels (`1. /setup-matt-pocock-skills`, `2. /wayfinder (Chart)`, `3. /wayfinder (Resolve)`, `4. /to-spec`, `5. /to-tickets`, `6. /implement`).
- **Auto-Discovery in `AsciinemaPlayer.vue`**: On mount, `AsciinemaPlayer.vue` parses embedded `"m"` marker events directly from the `.cast` file (computing effective playback timestamps respecting `idleTimeLimit`) so recordings are self-contained and resilient to trimming. Slide frontmatter `markers: [[timestamp, label], ...]` remains supported as an optional override.

### 2. Slidev Chapter UI (Variant A: Compact Header Chapter Pills) & Conflict-Free Stage Controls
- **Header Chapter Stepper Bar (`cast-full.vue` / `AsciinemaPlayer.vue`)**: When a recording has chapter markers, `cast-full.vue` renders a compact row of clickable chapter pills (`1. /setup-skills`, `2. /wayfinder (Chart)`, …) and `◀ Prev` / `▶ Resume` / `Next ▶` buttons in the header bar, preserving ~85% viewport height and 100% terminal width.
- **Auto-Pause on Markers**: `pauseOnMarkers` defaults to `true` whenever markers are present. Reaching a marker pauses playback and shows an amber `⏸ Auto-Paused at Marker` banner/pill with a one-click `▶ Resume` action for live stage commentary.
- **Slidev-Safe Keyboard Shortcuts**: Chapter stepping binds `[` (previous chapter), `]` (next chapter), and `p` (play/resume) with `event.stopPropagation()`, avoiding any collision with Slidev's slide-advance keys (`Space`, `ArrowRight`, `ArrowLeft`).
