#!/usr/bin/env bash
# setup-workspaces.sh — Cast post-processor and trace extractor
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

BASELINE_DIR="$DEMOS_ROOT/parts_tracker_baseline"
SKILLED_DIR="$DEMOS_ROOT/parts_tracker_skilled"
COMPREHENSION_DIR="$DEMOS_ROOT/parts_tracker_comprehension"
RECORDINGS_RAW="$PRESENTATION_ROOT/recordings/raw"
RECORDINGS_FINAL="$PRESENTATION_ROOT/recordings/final"
TRACES_DIR="$PRESENTATION_ROOT/artifacts/traces"

usage() {
  cat <<EOF
Usage: $(basename "$0") <subcommand>

Subcommands:
  postprocess-casts   Run sanitize-cast.py, mark-cast.py --list, and trim-cast.py across captured .cast files
  extract-traces      Export and compare Session Traces from ~/.gemini/**/brain/ via agy-brain-explorer
  status              Print current state of all 3 workspaces, .cast recordings, and extracted traces
EOF
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
    python3 "$trim_script" "$final_file" --in-place --hold 3.0
    python3 "$mark_script" "$final_file" --list
    python3 "$trim_script" "$final_file" --info
  done
}

extract_traces() {
  mkdir -p "$TRACES_DIR"
  local explorer="$PRESENTATION_ROOT/.agents/skills/agy-brain-explorer/scripts/agy-brain-explorer.py"
  echo "=== Discovering Sessions Across Experiment Projects ==="
  uv run "$explorer" --by-project
  for proj in parts_tracker_baseline parts_tracker_skilled parts_tracker_comprehension; do
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
