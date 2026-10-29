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

Validated via interactive prototypes:
- [05-stop-points.html](../prototypes/05-stop-points.html) (UI variant & state machine prototype)
- [06-baseline-cast-player.html](../prototypes/06-baseline-cast-player.html) (self-contained live browser test-drive harness for `01-baseline.cast`)

### 1. Hybrid Embedded `.cast` `"m"` Markers + Post-Process Labeler (`mark-cast.py`)
- **Recording & Post-Processing**: Stop points are stored directly inside the `.cast` file as native asciicast `"m"` marker events. During `asciinema rec`, the operator can press `Ctrl+x` at stop points or run [mark-cast.py](../prototypes/mark-cast.py) (`--auto-baseline` for the 7 Baseline Run milestones; `--auto-skilled` for the 6 Skilled Run skill invocations), which detects stdout frame boundaries (inserting `[0.0, "m", "<label>"]` immediately after the frame-completing `"o"` event before user pauses so `pauseOnMarkers` pauses with the prompt/question already drawn on screen).
- **Auto-Discovery & `asciicast v3` → `v2` Normalization in `AsciinemaPlayer.vue`**: On mount, `AsciinemaPlayer.vue` and [06-baseline-cast-player.html](../prototypes/06-baseline-cast-player.html) parse the `.cast` stream, normalize `asciicast v3` headers/relative-`dt` events (and `"x"` exit holds) into `asciicast v2` in memory (`{ data: v2Text }`) so `asciinema-player` `< 3.10.0` (`^3.8.0`/`3.9.0`) never fails with the `💥` parser error, and extract embedded `"m"` markers with idle-capped playback timestamps. Slide frontmatter `markers: [[timestamp, label], ...]` remains supported as an optional override.

### 2. Slidev Chapter UI (Variant A: Compact Header Chapter Pills) & Conflict-Free Stage Controls
- **Header Chapter Stepper Bar (`cast-full.vue` / `AsciinemaPlayer.vue`)**: When a recording has chapter markers, `cast-full.vue` renders a compact row of clickable chapter pills (`1. /setup-skills`, `2. /wayfinder (Chart)`, …) and `◀ Prev` / `▶ Resume` / `Next ▶` buttons in the header bar, preserving ~85% viewport height and 100% terminal width.
- **Auto-Pause on Markers**: `pauseOnMarkers` defaults to `true` whenever markers are present. Reaching a marker pauses playback and shows an amber `⏸ Auto-Paused at Marker` banner/pill with a one-click `▶ Resume` action for live stage commentary.
- **Adaptive Per-Segment Playback Speed (`>= 2x`, `<= 30s` per segment)**: `AsciinemaPlayer.vue` and the test-drive player compute each breakpoint-bounded segment's idle-capped duration and set its speed multiplier to $\max(\text{minSpeed}, \lceil D_{1\times} / 30\text{s} \rceil)$ with a minimum speed of `2x` and a target maximum of `30s` per segment (e.g., `2x` for short setup/Q&A segments, `3x` for planning, `25x` for the 12.5-minute build, `4x` for launching the iOS simulator). Current playback speed is prominently displayed in the header (`⚡ Speed: Nx`), on each chapter pill, and in the bottom HUD pill (`Playback speed: Nx`).
- **Slidev-Safe Keyboard Shortcuts**: Chapter stepping binds `[` (previous chapter), `]` (next chapter), and `p` (play/resume) with `event.stopPropagation()`, avoiding any collision with Slidev's slide-advance keys (`Space`, `ArrowRight`, `ArrowLeft`).
