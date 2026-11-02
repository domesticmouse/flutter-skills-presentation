#!/usr/bin/env python3
"""
mark-cast.py: Inspect, search, relabel, or inject asciicast ("m") chapter markers in .cast files (v2 & v3).

Supports:
1. --list: Display all existing "m" marker events with raw, 1x, and time-warped playback timestamps.
2. --search <regex>: Search terminal stdout ("o") events for a pattern and print event index + timestamps.
3. --auto-baseline / --auto-skilled / --auto-comprehension: Auto-inject canonical chapter markers for each run.
4. --add-pattern <regex> <label>: Insert an "m" marker immediately after (or --before) the stdout frame matching <regex>.
5. --add-time <seconds> <label>: Insert an "m" marker at a specific timestamp (raw seconds by default, or --effective-time for 1x).
6. --add-event <event_idx> <label>: Insert an "m" marker immediately after event #<event_idx>.
7. --relabel "Label 1" "Label 2" ...: Rename existing "m" markers in order.
8. --clear: Remove all existing "m" markers before applying any new marker operations.
"""

import argparse
import json
import math
import re
import sys
from typing import Any

CANONICAL_BASELINE_MARKERS: list[tuple[str, re.Pattern[str]]] = [
    ("1. Project Created", re.compile(r"All done!.*parts_tracker_baseline", re.DOTALL)),
    ("2. Initial Git Commit", re.compile(r"Initial scaffold|root-commit", re.DOTALL)),
    ("3. Launch agy", re.compile(r"Antigravity CLI.*?\? for shortcuts", re.DOTALL)),
    (
        "4. Q1: Clarifying Question",
        re.compile(
            r"Where would you like to store.*?enter Select|enter Select", re.DOTALL
        ),
    ),
    (
        "5. Q2: Clarifying Question",
        re.compile(
            r"Which additional features.*?enter Submit|enter Submit|enter Select",
            re.DOTALL,
        ),
    ),
    (
        "6. Q3: Clarifying Question",
        re.compile(
            r"What UI style would you prefer.*?enter Select|enter Select", re.DOTALL
        ),
    ),
    (
        "7. Build Complete",
        re.compile(r"Verified build completed successfully\.|flutter test", re.DOTALL),
    ),
    ("8. Run App", re.compile(r"Please run the app\.", re.DOTALL)),
    ("9. Clear Session (/clear)", re.compile(r"/clear", re.DOTALL)),
    ("10. Codebase Review", re.compile(r"Please review the codebase", re.DOTALL)),
]

CANONICAL_SKILLED_MARKERS: list[tuple[str, re.Pattern[str]]] = [
    ("1. Project Created", re.compile(r"All done!.*parts_tracker_skilled", re.DOTALL)),
    ("2. Initial Git Commit", re.compile(r"Initial scaffold|root-commit", re.DOTALL)),
    (
        "3. Install Matt Pocock Skills",
        re.compile(r"npx skills@latest add mattpocock/skills", re.DOTALL),
    ),
    ("4. Launch agy", re.compile(r"Antigravity CLI.*?\? for shortcuts", re.DOTALL)),
    ("5. /wayfinder (Chart)", re.compile(r"/wayfinder\s+I'd like to build", re.DOTALL)),
    ("6. /wayfinder (Resolve)", re.compile(r"/wayfinder\b", re.DOTALL)),
    ("7. /to-spec", re.compile(r"/to-spec\b", re.DOTALL)),
    ("8. /to-tickets", re.compile(r"/to-tickets\b", re.DOTALL)),
    ("9. /implement", re.compile(r"/implement\b", re.DOTALL)),
    ("10. Run App", re.compile(r"Please run the app\.", re.DOTALL)),
    ("11. Clear Session (/clear)", re.compile(r"/clear", re.DOTALL)),
    ("12. Codebase Review", re.compile(r"Please review the codebase", re.DOTALL)),
]

CANONICAL_COMPREHENSION_MARKERS: list[tuple[str, re.Pattern[str]]] = [
    (
        "1. Install Comprehension Skills",
        re.compile(r"npx skills@latest add domesticmouse/skills", re.DOTALL),
    ),
    ("2. Launch agy", re.compile(r"Antigravity CLI.*?\? for shortcuts", re.DOTALL)),
    ("3. /teach-code Prompt", re.compile(r"/teach-code\s+I know React", re.DOTALL)),
    ("4. Curriculum & Lesson 0001 Built", re.compile(r"build\.py --check", re.DOTALL)),
]

ANSI_ESCAPE_RE = re.compile(
    r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~]|\][^\x07\x1B]*(?:\x07|\x1B\\))"
)


def strip_ansi(text: str) -> str:
    return ANSI_ESCAPE_RE.sub("", text)


def load_cast(path: str) -> tuple[dict[str, Any], list[list[Any]], int]:
    with open(path, "r", encoding="utf-8") as f:
        lines = [
            line.strip()
            for line in f
            if line.strip() and not line.strip().startswith("#")
        ]
    if not lines:
        raise ValueError(f"Empty cast file: {path}")
    header = json.loads(lines[0])
    version = int(header.get("version", 2))
    events = [json.loads(line) for line in lines[1:]]
    return header, events, version


def compute_timings(
    header: dict[str, Any], events: list[list[Any]], version: int
) -> list[tuple[int, float, float, str, Any]]:
    """
    Returns list of (index, raw_abs_time, effective_playback_time, event_code, payload).
    Handles both v2 (absolute timestamps) and v3 (relative dt intervals).
    """
    idle_limit = header.get("idle_time_limit")
    if idle_limit is None and isinstance(header.get("term"), dict):
        idle_limit = header.get("idle_time_limit")
    idle_cap = float(idle_limit) if idle_limit is not None else None

    result: list[tuple[int, float, float, str, Any]] = []
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


def list_markers(
    header: dict[str, Any],
    events: list[list[Any]],
    version: int,
    min_speed: float = 2.0,
    max_segment_sec: float = 30.0,
) -> None:
    timings = compute_timings(header, events, version)
    markers = [row for row in timings if row[3] == "m"]
    print(
        f"Format: asciicast-v{version} | Total events: {len(events)} | Markers: {len(markers)}"
    )
    if not markers:
        print("  (no 'm' marker events found)")
        return
    prev_eff = 0.0
    warped_abs = 0.0
    prev_label = "0. Start"
    for num, (idx, raw_t, eff_t, _, label) in enumerate(markers, start=1):
        seg_dur = max(0.0, eff_t - prev_eff)
        spd = (
            max(min_speed, float(math.ceil(seg_dur / max_segment_sec)))
            if seg_dur / min_speed > max_segment_sec
            else min_speed
        )
        warped_dur = seg_dur / spd
        warped_abs += warped_dur
        print(
            f"  [{num}] event #{idx:04d} | raw={raw_t:6.2f}s | 1x={eff_t:6.2f}s | "
            f"seg={warped_dur:4.1f}s @ {spd:g}x | warped={warped_abs:5.1f}s | label={label!r}"
        )
        prev_eff = eff_t
        prev_label = str(label)
    non_exit = [row for row in timings if row[3] != "x"]
    if non_exit and non_exit[-1][2] > prev_eff + 0.05:
        tail_eff = non_exit[-1][2]
        seg_dur = max(0.0, tail_eff - prev_eff)
        spd = (
            max(min_speed, float(math.ceil(seg_dur / max_segment_sec)))
            if seg_dur / min_speed > max_segment_sec
            else min_speed
        )
        warped_dur = seg_dur / spd
        warped_abs += warped_dur
        print(
            f"  [End] after {prev_label!r} | 1x_seg={seg_dur:6.2f}s | "
            f"seg={warped_dur:4.1f}s @ {spd:g}x | total_warped={warped_abs:5.1f}s"
        )


def search_events(
    header: dict[str, Any],
    events: list[list[Any]],
    version: int,
    pattern_str: str,
    limit: int = 30,
) -> None:
    pattern = re.compile(pattern_str, re.IGNORECASE | re.DOTALL)
    timings = compute_timings(header, events, version)
    matches = 0
    rolling = ""
    print(f"Searching for pattern {pattern_str!r} across {len(events)} events...")
    for idx, raw_t, eff_t, code, data in timings:
        if code != "o":
            continue
        clean = strip_ansi(str(data))
        rolling = (rolling + clean)[-800:]
        if pattern.search(clean) or pattern.search(rolling):
            snippet = " ".join(clean.split())
            if not snippet:
                snippet = " ".join(rolling[-120:].split())
            print(
                f"  event #{idx:04d} | raw={raw_t:6.2f}s | 1x={eff_t:6.2f}s | {snippet[:90]!r}"
            )
            matches += 1
            rolling = ""
            if matches >= limit:
                print(
                    f"  ... stopped at {limit} matches (use a more specific regex to narrow)"
                )
                break
    if matches == 0:
        print("  (no matching stdout events found)")


def relabel_markers(events: list[list[Any]], labels: list[str]) -> int:
    label_idx = 0
    updated = 0
    for ev in events:
        if len(ev) >= 3 and ev[1] == "m" and label_idx < len(labels):
            ev[2] = labels[label_idx]
            label_idx += 1
            updated += 1
    return updated


def auto_inject_markers(
    header: dict[str, Any],
    events: list[list[Any]],
    version: int,
    marker_specs: list[tuple[str, re.Pattern[str]]],
    insert_after: bool = True,
) -> tuple[list[list[Any]], list[str]]:
    """
    Scan stdout ('o') events for the patterns in marker_specs and insert 'm' markers
    with dt=0.0 (v3) or same timestamp (v2).
    """
    canonical_labels = {label for label, _ in marker_specs}
    # Strip previously auto-injected canonical markers so re-running is idempotent
    events = [
        ev
        for ev in events
        if not (len(ev) >= 3 and ev[1] == "m" and ev[2] in canonical_labels)
    ]

    new_events: list[list[Any]] = []
    target_idx = 0
    injected: list[str] = []
    rolling_window = ""

    for ev in events:
        if insert_after:
            new_events.append(ev)
        if target_idx < len(marker_specs) and len(ev) >= 3 and ev[1] == "o":
            clean_chunk = strip_ansi(str(ev[2]))
            rolling_window = (rolling_window + clean_chunk)[-1500:]
            # Allow matching either the next expected marker OR a subsequent marker if an optional one didn't appear
            for lookahead in range(target_idx, len(marker_specs)):
                label, pattern = marker_specs[lookahead]
                if pattern.search(rolling_window):
                    marker_time = 0.0 if version == 3 else ev[0]
                    new_events.append([marker_time, "m", label])
                    injected.append(label)
                    target_idx = lookahead + 1
                    rolling_window = ""
                    break
        if not insert_after:
            new_events.append(ev)

    return new_events, injected


def add_pattern_marker(
    events: list[list[Any]],
    version: int,
    pattern_str: str,
    label: str,
    occurrence: int = 1,
    insert_after: bool = True,
) -> tuple[list[list[Any]], int | None]:
    pattern = re.compile(pattern_str, re.DOTALL)
    new_events: list[list[Any]] = []
    rolling_window = ""
    seen = 0
    inserted_at: int | None = None

    for idx, ev in enumerate(events):
        if insert_after:
            new_events.append(ev)
        if inserted_at is None and len(ev) >= 3 and ev[1] == "o":
            clean_chunk = strip_ansi(str(ev[2]))
            rolling_window = (rolling_window + clean_chunk)[-1500:]
            if pattern.search(rolling_window):
                seen += 1
                rolling_window = ""
                if seen == occurrence:
                    marker_time = 0.0 if version == 3 else ev[0]
                    new_events.append([marker_time, "m", label])
                    inserted_at = idx
        if not insert_after:
            new_events.append(ev)

    return new_events, inserted_at


def add_event_marker(
    events: list[list[Any]],
    version: int,
    target_idx: int,
    label: str,
    insert_after: bool = True,
) -> tuple[list[list[Any]], bool]:
    if target_idx < 0 or target_idx >= len(events):
        return events, False
    new_events: list[list[Any]] = []
    for idx, ev in enumerate(events):
        if idx == target_idx and not insert_after:
            marker_time = 0.0 if version == 3 else ev[0]
            new_events.append([marker_time, "m", label])
        new_events.append(ev)
        if idx == target_idx and insert_after:
            marker_time = 0.0 if version == 3 else ev[0]
            new_events.append([marker_time, "m", label])
    return new_events, True


def add_time_marker(
    header: dict[str, Any],
    events: list[list[Any]],
    version: int,
    target_sec: float,
    label: str,
    use_effective_time: bool = False,
) -> tuple[list[list[Any]], int]:
    timings = compute_timings(header, events, version)
    chosen_idx = 0
    for idx, raw_t, eff_t, _, _ in timings:
        t_compare = eff_t if use_effective_time else raw_t
        if t_compare <= target_sec:
            chosen_idx = idx
        else:
            break
    events, _ = add_event_marker(events, version, chosen_idx, label, insert_after=True)
    return events, chosen_idx


def save_cast(path: str, header: dict[str, Any], events: list[list[Any]]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write(json.dumps(header, ensure_ascii=False) + "\n")
        f.writelines(json.dumps(ev, ensure_ascii=False) + "\n" for ev in events)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Inspect, search, relabel, or inject 'm' chapter markers in .cast files."
    )
    parser.add_argument("input", help="Input .cast file path")
    parser.add_argument(
        "-o", "--output", help="Output .cast file path (or use --in-place)"
    )
    parser.add_argument(
        "-i", "--in-place", action="store_true", help="Modify input .cast file in place"
    )
    parser.add_argument(
        "--list", action="store_true", help="List existing 'm' markers and timestamps"
    )
    parser.add_argument(
        "--search",
        metavar="REGEX",
        help="Search stdout events for REGEX and print event indices/timestamps",
    )
    parser.add_argument(
        "--clear",
        action="store_true",
        help="Remove all existing 'm' markers before adding new ones",
    )
    parser.add_argument(
        "--relabel", nargs="+", help="Relabel existing 'm' markers in sequence"
    )
    parser.add_argument(
        "--auto-baseline",
        action="store_true",
        help="Auto-inject the canonical Baseline Run chapter markers",
    )
    parser.add_argument(
        "--auto-skilled",
        action="store_true",
        help="Auto-inject the canonical Skilled Run chapter markers",
    )
    parser.add_argument(
        "--auto-comprehension",
        action="store_true",
        help="Auto-inject the canonical Comprehension Run chapter markers",
    )
    parser.add_argument(
        "--add-pattern",
        nargs=2,
        action="append",
        metavar=("REGEX", "LABEL"),
        help="Insert a marker labeled LABEL right after stdout matches REGEX (repeatable; use regex#N for Nth match)",
    )
    parser.add_argument(
        "--add-time",
        nargs=2,
        action="append",
        metavar=("SECONDS", "LABEL"),
        help="Insert a marker labeled LABEL at timestamp SECONDS (repeatable; raw time by default, or 1x with --effective-time)",
    )
    parser.add_argument(
        "--effective-time",
        action="store_true",
        help="Interpret --add-time SECONDS as idle-capped 1x playback time instead of raw elapsed time",
    )
    parser.add_argument(
        "--add-event",
        nargs=2,
        action="append",
        metavar=("EVENT_IDX", "LABEL"),
        help="Insert a marker labeled LABEL after event #EVENT_IDX (repeatable)",
    )
    parser.add_argument(
        "--before",
        action="store_true",
        help="Insert --add-pattern / --add-event markers immediately before the target event instead of after",
    )
    args = parser.parse_args()

    header, events, version = load_cast(args.input)

    if args.search:
        search_events(header, events, version, args.search)
        if not (
            args.clear
            or args.relabel
            or args.auto_baseline
            or args.auto_skilled
            or args.auto_comprehension
            or args.add_pattern
            or args.add_time
            or args.add_event
        ):
            return 0

    mutating = bool(
        args.clear
        or args.relabel
        or args.auto_baseline
        or args.auto_skilled
        or args.auto_comprehension
        or args.add_pattern
        or args.add_time
        or args.add_event
    )

    if args.list and not mutating:
        list_markers(header, events, version)
        return 0

    if args.clear:
        before_count = sum(1 for ev in events if len(ev) >= 2 and ev[1] == "m")
        events = [ev for ev in events if not (len(ev) >= 2 and ev[1] == "m")]
        print(f"Cleared {before_count} existing marker(s).")

    if args.relabel:
        count = relabel_markers(events, args.relabel)
        print(f"Relabeled {count} marker(s).")

    if args.auto_baseline:
        events, notes = auto_inject_markers(
            header, events, version, CANONICAL_BASELINE_MARKERS, insert_after=True
        )
        for note in notes:
            print(f"[auto-baseline] + {note}")

    if args.auto_skilled:
        events, notes = auto_inject_markers(
            header, events, version, CANONICAL_SKILLED_MARKERS, insert_after=True
        )
        for note in notes:
            print(f"[auto-skilled] + {note}")

    if args.auto_comprehension:
        events, notes = auto_inject_markers(
            header, events, version, CANONICAL_COMPREHENSION_MARKERS, insert_after=True
        )
        for note in notes:
            print(f"[auto-comprehension] + {note}")

    if args.add_pattern:
        for raw_pat, label in args.add_pattern:
            occ = 1
            pat = raw_pat
            if "#" in raw_pat and raw_pat.rsplit("#", 1)[1].isdigit():
                pat, occ_str = raw_pat.rsplit("#", 1)
                occ = int(occ_str)
            events, idx = add_pattern_marker(
                events,
                version,
                pat,
                label,
                occurrence=occ,
                insert_after=not args.before,
            )
            if idx is not None:
                print(
                    f"[add-pattern] + {label!r} at event #{idx:04d} (pattern={pat!r}, occurrence={occ})"
                )
            else:
                print(
                    f"[add-pattern] WARNING: pattern {pat!r} (occurrence={occ}) not found for {label!r}"
                )

    if args.add_event:
        for idx_str, label in args.add_event:
            target_idx = int(idx_str)
            events, ok = add_event_marker(
                events, version, target_idx, label, insert_after=not args.before
            )
            if ok:
                print(f"[add-event] + {label!r} at event #{target_idx:04d}")
            else:
                print(
                    f"[add-event] WARNING: event #{target_idx} out of range (0..{len(events) - 1})"
                )

    if args.add_time:
        for sec_str, label in args.add_time:
            target_sec = float(sec_str)
            events, idx = add_time_marker(
                header,
                events,
                version,
                target_sec,
                label,
                use_effective_time=args.effective_time,
            )
            mode = "1x" if args.effective_time else "raw"
            print(
                f"[add-time] + {label!r} at {mode}={target_sec:.2f}s (event #{idx:04d})"
            )

    list_markers(header, events, version)

    out_path = args.input if args.in_place else args.output
    if out_path:
        save_cast(out_path, header, events)
        print(f"Saved updated cast to {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
