#!/usr/bin/env python3
"""
mark-cast.py: Inspect, relabel, or auto-inject asciicast ("m") chapter markers in .cast files (v2 & v3).

Supports:
1. --list: Display all existing "m" marker events with raw and idle-capped playback timestamps.
2. --relabel "Label 1" "Label 2" ...: Rename existing unlabeled (or placeholder) "m" markers in order
   (e.g., when pressed via Ctrl+x during live recording).
3. --auto-skilled: Scan stdout ("o") events for canonical Matt Pocock skill invocations
   (/setup-matt-pocock-skills, /wayfinder, /to-spec, /to-tickets, /implement) and either relabel
   existing Ctrl+x markers or insert "m" marker events immediately before each command boundary.
4. --add <seconds> <label>: Insert an "m" marker event at a specific raw timestamp.
"""

import argparse
import json
import re
import sys
from typing import Any, Dict, List, Tuple

CANONICAL_BASELINE_MARKERS: List[Tuple[str, re.Pattern[str]]] = [
    ("1. Project Created", re.compile(r"All done!.*flutter-parts-experiment", re.DOTALL)),
    ("2. Launch agy", re.compile(r"Antigravity CLI.*?\? for shortcuts", re.DOTALL)),
    ("3. Q1: Data Storage", re.compile(r"Where would you like to store.*?enter Select", re.DOTALL)),
    ("4. Q2: Features", re.compile(r"Which additional features.*?enter Submit", re.DOTALL)),
    ("5. Q3: UI Style", re.compile(r"What UI style would you prefer.*?enter Select", re.DOTALL)),
    ("6. Implementation Plan", re.compile(r"1 artifact · /artifact to review.*?\? for shortcutsGemini", re.DOTALL)),
    ("7. Build Complete", re.compile(r"Verified build completed successfully\..*?\? for shortcuts", re.DOTALL)),
]

CANONICAL_SKILLED_MARKERS: List[Tuple[str, re.Pattern[str]]] = [
    ("1. /setup-matt-pocock-skills", re.compile(r"/setup-matt-pocock-skills")),
    ("2. /wayfinder (Chart)", re.compile(r"/wayfinder\b")),
    ("3. /wayfinder (Resolve)", re.compile(r"/wayfinder\b")),
    ("4. /to-spec", re.compile(r"/to-spec\b")),
    ("5. /to-tickets", re.compile(r"/to-tickets\b")),
    ("6. /implement", re.compile(r"/implement\b")),
]

ANSI_ESCAPE_RE = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")


def strip_ansi(text: str) -> str:
    return ANSI_ESCAPE_RE.sub("", text)


def load_cast(path: str) -> Tuple[Dict[str, Any], List[List[Any]], int]:
    with open(path, "r", encoding="utf-8") as f:
        lines = [line.strip() for line in f if line.strip() and not line.strip().startswith("#")]
    if not lines:
        raise ValueError(f"Empty cast file: {path}")
    header = json.loads(lines[0])
    version = int(header.get("version", 2))
    events = [json.loads(line) for line in lines[1:]]
    return header, events, version


def compute_timings(
    header: Dict[str, Any], events: List[List[Any]], version: int
) -> List[Tuple[int, float, float, str, Any]]:
    """
    Returns list of (index, raw_abs_time, effective_playback_time, event_code, payload).
    Handles both v2 (absolute timestamps) and v3 (relative dt intervals).
    """
    idle_limit = header.get("idle_time_limit")
    if idle_limit is None and isinstance(header.get("term"), dict):
        idle_limit = header.get("idle_time_limit")
    idle_cap = float(idle_limit) if idle_limit is not None else None

    result: List[Tuple[int, float, float, str, Any]] = []
    raw_abs = 0.0
    eff_abs = 0.0
    prev_raw = 0.0

    for idx, ev in enumerate(events):
        t_val = float(ev[0])
        code = str(ev[1])
        data = ev[2] if len(ev) > 2 else ""
        if version == 3:
            dt = t_val
            raw_abs += dt
        else:
            raw_abs = t_val
            dt = raw_abs - prev_raw
            prev_raw = raw_abs
        eff_dt = min(dt, idle_cap) if idle_cap is not None else dt
        eff_abs += eff_dt
        result.append((idx, raw_abs, eff_abs, code, data))
    return result


def list_markers(header: Dict[str, Any], events: List[List[Any]], version: int) -> None:
    timings = compute_timings(header, events, version)
    markers = [row for row in timings if row[3] == "m"]
    print(f"Format: asciicast-v{version} | Total events: {len(events)} | Markers: {len(markers)}")
    if not markers:
        print("  (no 'm' marker events found)")
        return
    for num, (idx, raw_t, eff_t, _, label) in enumerate(markers, start=1):
        print(f"  [{num}] event #{idx:04d} | raw={raw_t:6.2f}s | playback={eff_t:6.2f}s | label={label!r}")


def relabel_markers(events: List[List[Any]], labels: List[str]) -> int:
    label_idx = 0
    updated = 0
    for ev in events:
        if len(ev) >= 3 and ev[1] == "m" and label_idx < len(labels):
            ev[2] = labels[label_idx]
            label_idx += 1
            updated += 1
    return updated


def auto_inject_markers(
    header: Dict[str, Any],
    events: List[List[Any]],
    version: int,
    marker_specs: List[Tuple[str, re.Pattern[str]]],
    insert_after: bool = False,
) -> Tuple[List[List[Any]], List[str]]:
    """
    If existing 'm' markers exist, relabel them with marker_specs.
    Otherwise, scan stdout ('o') events for the patterns and insert 'm' markers
    with dt=0.0 (v3) or same timestamp (v2).
    """
    existing_m = [ev for ev in events if len(ev) >= 3 and ev[1] == "m"]
    canonical_labels = [label for label, _ in marker_specs]
    unlabeled_m = [ev for ev in existing_m if ev[2] not in canonical_labels]

    if unlabeled_m:
        count = relabel_markers(events, canonical_labels)
        return events, [f"Relabeled {count} existing 'm' marker(s)"]

    # Strip previously auto-injected canonical markers so re-running is idempotent
    events = [ev for ev in events if not (len(ev) >= 3 and ev[1] == "m" and ev[2] in canonical_labels)]

    new_events: List[List[Any]] = []
    target_idx = 0
    injected: List[str] = []
    rolling_window = ""

    for ev in events:
        if insert_after:
            new_events.append(ev)
        if target_idx < len(marker_specs) and len(ev) >= 3 and ev[1] == "o":
            clean_chunk = strip_ansi(str(ev[2]))
            rolling_window = (rolling_window + clean_chunk)[-1200:]
            label, pattern = marker_specs[target_idx]
            if pattern.search(rolling_window):
                marker_time = 0.0 if version == 3 else ev[0]
                new_events.append([marker_time, "m", label])
                injected.append(label)
                target_idx += 1
                rolling_window = ""
        if not insert_after:
            new_events.append(ev)

    return new_events, injected


def save_cast(path: str, header: Dict[str, Any], events: List[List[Any]]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write(json.dumps(header, ensure_ascii=False) + "\n")
        for ev in events:
            f.write(json.dumps(ev, ensure_ascii=False) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description="Inspect, relabel, or inject 'm' chapter markers in .cast files.")
    parser.add_argument("input", help="Input .cast file path")
    parser.add_argument("-o", "--output", help="Output .cast file path (or use --in-place)")
    parser.add_argument("-i", "--in-place", action="store_true", help="Modify input .cast file in place")
    parser.add_argument("--list", action="store_true", help="List existing 'm' markers and timestamps")
    parser.add_argument("--relabel", nargs="+", help="Relabel existing 'm' markers in sequence")
    parser.add_argument(
        "--auto-baseline",
        action="store_true",
        help="Auto-label or inject the 7 canonical Baseline Run chapter markers",
    )
    parser.add_argument(
        "--auto-skilled",
        action="store_true",
        help="Auto-label or inject the 6 canonical Skilled Run chapter markers",
    )
    args = parser.parse_args()

    header, events, version = load_cast(args.input)

    if args.list and not (args.relabel or args.auto_baseline or args.auto_skilled):
        list_markers(header, events, version)
        return 0

    if args.relabel:
        count = relabel_markers(events, args.relabel)
        print(f"Relabeled {count} marker(s).")

    if args.auto_baseline:
        events, notes = auto_inject_markers(
            header, events, version, CANONICAL_BASELINE_MARKERS, insert_after=True
        )
        for note in notes:
            print(f"[auto-baseline] {note}")

    if args.auto_skilled:
        events, notes = auto_inject_markers(
            header, events, version, CANONICAL_SKILLED_MARKERS, insert_after=False
        )
        for note in notes:
            print(f"[auto-skilled] {note}")

    list_markers(header, events, version)

    out_path = args.input if args.in_place else args.output
    if out_path:
        save_cast(out_path, header, events)
        print(f"Saved updated cast to {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
