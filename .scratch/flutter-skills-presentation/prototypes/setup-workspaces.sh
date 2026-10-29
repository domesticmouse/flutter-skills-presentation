#!/usr/bin/env bash
# setup-workspaces.sh — Operator workspace initializer, cast post-processor, and trace extractor
# for the Flutter Skills Presentation 3-run experiment.

set -euo pipefail

PRESENTATION_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
if [[ -z "${DEMOS_ROOT:-}" ]]; then
  if [[ -d "$PRESENTATION_ROOT/experiments" ]]; then
    DEMOS_ROOT="$PRESENTATION_ROOT/experiments"
  else
    DEMOS_ROOT="$HOME/Demos/flutter-parts-experiment"
  fi
fi
BASELINE_DIR="$DEMOS_ROOT/parts-tracker-baseline"
SKILLED_DIR="$DEMOS_ROOT/parts-tracker-skilled"
COMPREHENSION_DIR="$DEMOS_ROOT/parts-tracker-comprehension"
RECORDINGS_RAW="$PRESENTATION_ROOT/recordings/raw"
RECORDINGS_FINAL="$PRESENTATION_ROOT/recordings/final"
TRACES_DIR="$PRESENTATION_ROOT/artifacts/traces"

MATT_POCOCK_SKILLS=(
  setup-matt-pocock-skills
  wayfinder
  grilling
  domain-modeling
  prototype
  research
  to-spec
  to-tickets
  implement
  tdd
  code-review
  codebase-design
  diagnosing-bugs
  triage
  wizard
)

TEACH_SKILLS=(
  teach-code
  teach
)

usage() {
  cat <<EOF
Usage: $(basename "$0") <subcommand>

Subcommands:
  init-all            Initialize clean Baseline and Skilled workspaces + recordings directories
  init-baseline       Reset and initialize clean Baseline Run workspace (no project skills)
  init-skilled        Reset and initialize clean Skilled Run workspace (Matt Pocock skill pack)
  clone-comprehension Copy finished Baseline Run app into Comprehension Run workspace + install /teach-code
  postprocess-casts   Run mark-cast.py, sanitize-cast.py, and trim-cast.py across captured .cast files
  extract-traces      Export and compare Session Traces from ~/.gemini/**/brain/ via agy-brain-explorer
  status              Print current state of all 3 workspaces, .cast recordings, and extracted traces
EOF
}

init_dirs() {
  mkdir -p "$DEMOS_ROOT" "$RECORDINGS_RAW" "$RECORDINGS_FINAL" "$TRACES_DIR"
}

init_baseline() {
  init_dirs
  rm -rf "$BASELINE_DIR"
  mkdir -p "$BASELINE_DIR"
  git -C "$BASELINE_DIR" init -q
  echo "[OK] Initialized Baseline Run workspace (zero project skills): $BASELINE_DIR"
}

init_skilled() {
  init_dirs
  rm -rf "$SKILLED_DIR"
  mkdir -p "$SKILLED_DIR/.agents/skills"
  git -C "$SKILLED_DIR" init -q
  for skill in "${MATT_POCOCK_SKILLS[@]}"; do
    if [[ -d "$PRESENTATION_ROOT/.agents/skills/$skill" ]]; then
      cp -R "$PRESENTATION_ROOT/.agents/skills/$skill" "$SKILLED_DIR/.agents/skills/$skill"
    fi
  done
  echo "[OK] Initialized Skilled Run workspace (${#MATT_POCOCK_SKILLS[@]} Matt Pocock skills): $SKILLED_DIR"
}

clone_comprehension() {
  init_dirs
  if [[ ! -d "$BASELINE_DIR/lib" ]]; then
    echo "[ERROR] Baseline Run app ($BASELINE_DIR/lib) not found! Complete Run 1 (Baseline Run) first." >&2
    exit 1
  fi
  rm -rf "$COMPREHENSION_DIR"
  cp -R "$BASELINE_DIR" "$COMPREHENSION_DIR"
  mkdir -p "$COMPREHENSION_DIR/.agents/skills"
  for skill in "${TEACH_SKILLS[@]}"; do
    if [[ -d "$PRESENTATION_ROOT/.agents/skills/$skill" ]]; then
      cp -R "$PRESENTATION_ROOT/.agents/skills/$skill" "$COMPREHENSION_DIR/.agents/skills/$skill"
    fi
  done
  echo "[OK] Cloned Baseline Run app into Comprehension Run workspace + installed /teach-code: $COMPREHENSION_DIR"
}

postprocess_casts() {
  mkdir -p "$RECORDINGS_RAW" "$RECORDINGS_FINAL"
  local mark_script="$PRESENTATION_ROOT/.scratch/flutter-skills-presentation/prototypes/mark-cast.py"
  local sanitize_script="$PRESENTATION_ROOT/.agents/skills/asciinema/scripts/sanitize-cast.py"
  local trim_script="$PRESENTATION_ROOT/.agents/skills/asciinema/scripts/trim-cast.py"

  for cast_name in 01-baseline.cast 02-skilled.cast 03-comprehension.cast; do
    local raw_file="$RECORDINGS_RAW/$cast_name"
    local final_file="$RECORDINGS_FINAL/$cast_name"
    if [[ ! -f "$raw_file" ]]; then
      echo "[SKIP] $raw_file not recorded yet"
      continue
    fi
    echo "=== Processing $cast_name ==="
    python3 "$sanitize_script" "$raw_file" "$final_file"
    if [[ "$cast_name" == "02-skilled.cast" ]]; then
      python3 "$mark_script" "$final_file" --auto-skilled --in-place
    fi
    python3 "$trim_script" "$final_file" --in-place --hold 3.0
    python3 "$trim_script" "$final_file" --info
  done
}

extract_traces() {
  mkdir -p "$TRACES_DIR"
  local explorer="$PRESENTATION_ROOT/.agents/skills/agy-brain-explorer/scripts/agy-brain-explorer.py"
  echo "=== Discovering Sessions Across Experiment Projects ==="
  uv run "$explorer" --by-project
  for proj in parts-tracker-baseline parts-tracker-skilled parts-tracker-comprehension; do
    mkdir -p "$TRACES_DIR/$proj"
    uv run "$explorer" export --project "$proj" -o "$TRACES_DIR/$proj" || true
  done
  echo "[OK] Exported Markdown Session Traces to $TRACES_DIR"
}

show_status() {
  echo "=== Experiment Workspaces ($DEMOS_ROOT) ==="
  for dir in "$BASELINE_DIR" "$SKILLED_DIR" "$COMPREHENSION_DIR"; do
    if [[ -d "$dir" ]]; then
      local skill_count=0
      [[ -d "$dir/.agents/skills" ]] && skill_count=$(ls -1 "$dir/.agents/skills" | wc -l | tr -d ' ')
      echo "  [READY] $(basename "$dir") (skills: $skill_count)"
    else
      echo "  [MISSING] $(basename "$dir")"
    fi
  done
  echo "=== Recordings ($RECORDINGS_RAW -> $RECORDINGS_FINAL) ==="
  for cast_name in 01-baseline.cast 02-skilled.cast 03-comprehension.cast; do
    local raw_state="missing"
    local final_state="missing"
    [[ -f "$RECORDINGS_RAW/$cast_name" ]] && raw_state="present"
    [[ -f "$RECORDINGS_FINAL/$cast_name" ]] && final_state="present"
    echo "  $cast_name: raw=$raw_state | final=$final_state"
  done
}

cmd="${1:-status}"
case "$cmd" in
  init-all)
    init_baseline
    init_skilled
    ;;
  init-baseline)
    init_baseline
    ;;
  init-skilled)
    init_skilled
    ;;
  clone-comprehension)
    clone_comprehension
    ;;
  postprocess-casts)
    postprocess_casts
    ;;
  extract-traces)
    extract_traces
    ;;
  status)
    show_status
    ;;
  *)
    usage
    exit 1
    ;;
esac
