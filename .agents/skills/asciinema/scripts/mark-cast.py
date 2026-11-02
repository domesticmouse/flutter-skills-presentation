#!/usr/bin/env python3
"""
mark-cast.py: Inspect, search, add, move/replace, or remove asciicast ("m") chapter markers in .cast files (v2 & v3).

Capabilities:
1. --list: Display all existing "m" marker events with raw, 1x, and adaptive time-warped playback timestamps.
2. --inspect START[:END]: Print a table of events in range [START, END] with dt, raw, 1x, code, and stripped text.
3. --search REGEX [--context N]: Search stdout ("o") events for REGEX and print event index, timestamps, and N surrounding events.
4. --set TARGET WHERE LABEL: Move/replace existing marker TARGET (1-based index or label substring) to WHERE
   (regex pattern, regex#N, @event:IDX, @time:SEC, or @1x:SEC) with new LABEL.
5. --remove TARGET: Remove existing marker(s) matching 1-based index or label substring.
6. --add-pattern REGEX LABEL: Insert an "m" marker immediately after (or --before) the stdout frame matching REGEX (or REGEX#N).
7. --add-time SECONDS LABEL [--effective-time]: Insert an "m" marker at raw or 1x timestamp SECONDS.
8. --add-event EVENT_IDX LABEL: Insert an "m" marker immediately after (or --before) event #EVENT_IDX.
9. --relabel LABEL1 LABEL2 ...: Rename existing "m" markers in sequence.
10. --clear: Remove all existing "m" markers before applying additions.
11. --auto-baseline / --auto-skilled / --auto-comprehension: Auto-inject canonical chapter markers for the 3-run experiment.
12. --embed-html HTML_PATH: Re-compress the saved .cast file (gzip+base64) into EMBEDDED_CAST_GZ_B64 inside HTML_PATH.
"""

import argparse
import base64
import gzip
import json
import math
from pathlib import Path
import re
import sys
from typing import Any

CANONICAL_BASELINE_MARKERS: list[tuple[str, re.Pattern[str]]] = [
    (
        "1. Create Project",
        re.compile(r"flutter create --platforms=ios parts_tracker_baseline", re.DOTALL),
    ),
    ("2. Initial Git Commit", re.compile(r"root-commit.*Initial scaffold", re.DOTALL)),
    ("3. Launch agy", re.compile(r"Antigravity CLI.*?\? for shortcuts", re.DOTALL)),
    (
        "4. Q1: Clarifying Question",
        re.compile(
            r"Which features would you like to include.*?enter Submit|Where would you like to store.*?enter Select",
            re.DOTALL,
        ),
    ),
    (
        "5. Q2: Clarifying Question",
        re.compile(
            r"How should your parts inventory data be stored.*?enter Select|Which additional features.*?enter Submit",
            re.DOTALL,
        ),
    ),
    (
        "6. Q3: Clarifying Question",
        re.compile(
            r"Which visual style do you prefer.*?enter Select|What UI style would you prefer.*?enter Select",
            re.DOTALL,
        ),
    ),
    (
        "7. Build Complete",
        re.compile(
            r"PartDetailScreen.*?\? for shortcuts|Verified build completed successfully\.",
            re.DOTALL,
        ),
    ),
    ("8. Run App", re.compile(r"Please run the app\.", re.DOTALL)),
    ("9. Clear Session (/clear)", re.compile(r"/clear", re.DOTALL)),
    ("10. Codebase Review", re.compile(r"Please review the codebase", re.DOTALL)),
    ("11. Apply Review Fixes", re.compile(r"> please fix", re.DOTALL)),
]

CANONICAL_SKILLED_MARKERS: list[tuple[str, re.Pattern[str]]] = [
    (
        "1. Create Project",
        re.compile(r"flutter create --platforms=ios parts_tracker_skilled", re.DOTALL),
    ),
    ("2. Initial Git Commit", re.compile(r"root-commit.*Initial scaffold", re.DOTALL)),
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
) -> list[tuple[int, float, float, float, str, Any]]:
    """
    Returns list of (index, dt, raw_abs_time, effective_playback_time, event_code, payload).
    Handles both v2 (absolute timestamps) and v3 (relative dt intervals).
    """
    idle_limit = header.get("idle_time_limit")
    idle_cap = float(idle_limit) if idle_limit is not None else None

    result: list[tuple[int, float, float, float, str, Any]] = []
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
        result.append((idx, dt, raw_abs, eff_abs, code, data))
    return result


def list_markers(
    header: dict[str, Any],
    events: list[list[Any]],
    version: int,
    min_speed: float = 2.0,
    max_segment_sec: float = 30.0,
) -> None:
    timings = compute_timings(header, events, version)
    markers = [row for row in timings if row[4] == "m"]
    print(
        f"Format: asciicast-v{version} | Total events: {len(events)} | Markers: {len(markers)}"
    )
    if not markers:
        print("  (no 'm' marker events found)")
        return
    prev_eff = 0.0
    warped_abs = 0.0
    prev_label = "0. Start"
    for num, (idx, _dt, raw_t, eff_t, _, label) in enumerate(markers, start=1):
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
    non_exit = [row for row in timings if row[4] != "x"]
    if non_exit and non_exit[-1][3] > prev_eff + 0.05:
        tail_eff = non_exit[-1][3]
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


def inspect_range(
    header: dict[str, Any],
    events: list[list[Any]],
    version: int,
    spec: str,
) -> None:
    timings = compute_timings(header, events, version)
    if ":" in spec:
        start_s, end_s = spec.split(":", 1)
        start_idx = int(start_s) if start_s else 0
        end_idx = int(end_s) if end_s else start_idx + 40
    else:
        center = int(spec)
        start_idx = max(0, center - 10)
        end_idx = center + 10
    start_idx = max(0, start_idx)
    end_idx = min(len(timings) - 1, end_idx)
    print(f"Inspecting events #{start_idx:04d}..#{end_idx:04d} (of {len(timings)}):")
    for idx in range(start_idx, end_idx + 1):
        _, dt, raw_t, eff_t, code, data = timings[idx]
        clean = " ".join(strip_ansi(str(data)).split())
        marker_flag = " <-- MARKER" if code == "m" else ""
        print(
            f"  #{idx:04d} | dt={dt:5.2f}s | raw={raw_t:7.2f}s | 1x={eff_t:7.2f}s | "
            f"{code} | {clean[:95]!r}{marker_flag}"
        )


def search_events(
    header: dict[str, Any],
    events: list[list[Any]],
    version: int,
    pattern_str: str,
    context: int = 0,
    limit: int = 30,
) -> None:
    pattern = re.compile(pattern_str, re.IGNORECASE | re.DOTALL)
    timings = compute_timings(header, events, version)
    matches = 0
    rolling = ""
    print(f"Searching for pattern {pattern_str!r} across {len(events)} events...")
    for idx, _dt, raw_t, eff_t, code, data in timings:
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
            if context > 0:
                c_start = max(0, idx - context)
                c_end = min(len(timings) - 1, idx + context)
                for c_idx in range(c_start, c_end + 1):
                    _, c_dt, c_raw, c_eff, c_code, c_data = timings[c_idx]
                    c_clean = " ".join(strip_ansi(str(c_data)).split())
                    prefix = "    >>>" if c_idx == idx else "       "
                    print(
                        f"{prefix} #{c_idx:04d} dt={c_dt:5.2f}s raw={c_raw:6.2f}s 1x={c_eff:6.2f}s {c_code} -> {c_clean[:80]!r}"
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
    for idx, _dt, raw_t, eff_t, _, _ in timings:
        t_compare = eff_t if use_effective_time else raw_t
        if t_compare <= target_sec:
            chosen_idx = idx
        else:
            break
    events, _ = add_event_marker(events, version, chosen_idx, label, insert_after=True)
    return events, chosen_idx


def remove_marker_by_target(
    events: list[list[Any]], target: str
) -> tuple[list[list[Any]], list[str]]:
    """
    Remove marker(s) matching 1-based marker number (e.g. '1') or case-insensitive label substring.
    """
    is_num = target.isdigit()
    target_num = int(target) if is_num else -1
    target_lower = target.lower()

    new_events: list[list[Any]] = []
    removed_labels: list[str] = []
    marker_num = 0
    for ev in events:
        if len(ev) >= 2 and ev[1] == "m":
            marker_num += 1
            label = str(ev[2]) if len(ev) > 2 else ""
            if (is_num and marker_num == target_num) or (
                not is_num and target_lower in label.lower()
            ):
                removed_labels.append(f"[{marker_num}] {label}")
                continue
        new_events.append(ev)
    return new_events, removed_labels


def set_marker_by_target(
    header: dict[str, Any],
    events: list[list[Any]],
    version: int,
    target: str,
    where_spec: str,
    new_label: str,
    insert_after: bool = True,
) -> tuple[list[list[Any]], str]:
    """
    Replace/move an existing marker identified by 1-based index or label substring,
    placing the updated marker at WHERE_SPEC:
      - '@event:123' -> event index #123
      - '@time:12.5' -> raw timestamp 12.5s
      - '@1x:12.5'   -> idle-capped 1x timestamp 12.5s
      - 'regex' or 'regex#2' -> stdout pattern match
    """
    events_without, removed = remove_marker_by_target(events, target)
    removed_desc = ", ".join(removed) if removed else f"(no existing marker matched {target!r})"

    if where_spec.startswith("@event:"):
        ev_idx = int(where_spec.split(":", 1)[1])
        updated_events, ok = add_event_marker(
            events_without, version, ev_idx, new_label, insert_after=insert_after
        )
        loc_desc = f"event #{ev_idx:04d}" if ok else f"FAILED event #{ev_idx}"
    elif where_spec.startswith("@time:"):
        sec = float(where_spec.split(":", 1)[1])
        updated_events, idx = add_time_marker(
            header, events_without, version, sec, new_label, use_effective_time=False
        )
        loc_desc = f"raw={sec:.2f}s (event #{idx:04d})"
    elif where_spec.startswith("@1x:"):
        sec = float(where_spec.split(":", 1)[1])
        updated_events, idx = add_time_marker(
            header, events_without, version, sec, new_label, use_effective_time=True
        )
        loc_desc = f"1x={sec:.2f}s (event #{idx:04d})"
    else:
        occ = 1
        pat = where_spec
        if "#" in where_spec and where_spec.rsplit("#", 1)[1].isdigit():
            pat, occ_str = where_spec.rsplit("#", 1)
            occ = int(occ_str)
        updated_events, idx = add_pattern_marker(
            events_without,
            version,
            pat,
            new_label,
            occurrence=occ,
            insert_after=insert_after,
        )
        loc_desc = (
            f"event #{idx:04d} (pattern={pat!r}, occ={occ})"
            if idx is not None
            else f"WARNING: pattern {pat!r} not found"
        )

    return updated_events, f"Replaced {removed_desc} -> {new_label!r} at {loc_desc}"


def save_cast(path: str, header: dict[str, Any], events: list[list[Any]]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write(json.dumps(header, ensure_ascii=False) + "\n")
        f.writelines(json.dumps(ev, ensure_ascii=False) + "\n" for ev in events)


def embed_cast_in_html(cast_path: str, html_path: str) -> None:
    cast_bytes = Path(cast_path).read_bytes()
    gz_b64 = base64.b64encode(gzip.compress(cast_bytes, compresslevel=9)).decode(
        "ascii"
    )
    target_html = Path(html_path)
    content = target_html.read_text(encoding="utf-8")
    new_content, count = re.subn(
        r'const EMBEDDED_CAST_GZ_B64 = "[^"]+";',
        f'const EMBEDDED_CAST_GZ_B64 = "{gz_b64}";',
        content,
        count=1,
    )
    if count == 0:
        raise ValueError(f"Could not find EMBEDDED_CAST_GZ_B64 in {html_path}")
    target_html.write_text(new_content, encoding="utf-8")
    print(f"Updated EMBEDDED_CAST_GZ_B64 in {html_path} ({len(gz_b64)} chars)")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Inspect, search, add, move/replace, or remove 'm' chapter markers in .cast files."
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
        "--inspect",
        metavar="START[:END]",
        help="Inspect events in range START:END (or around event index START) with dt, raw, 1x, and stripped stdout",
    )
    parser.add_argument(
        "--search",
        metavar="REGEX",
        help="Search stdout events for REGEX and print event indices/timestamps",
    )
    parser.add_argument(
        "-C",
        "--context",
        type=int,
        default=0,
        metavar="N",
        help="Print N surrounding events before and after each --search match",
    )
    parser.add_argument(
        "--clear",
        action="store_true",
        help="Remove all existing 'm' markers before adding new ones",
    )
    parser.add_argument(
        "--remove",
        action="append",
        metavar="NUM_OR_LABEL",
        help="Remove a specific marker by 1-based number (e.g. 1) or label substring (repeatable)",
    )
    parser.add_argument(
        "--set",
        nargs=3,
        action="append",
        metavar=("NUM_OR_LABEL", "WHERE", "NEW_LABEL"),
        help="Move/replace marker NUM_OR_LABEL to WHERE (regex, regex#N, @event:IDX, @time:SEC, @1x:SEC) with NEW_LABEL",
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
        help="Insert --add-pattern / --add-event / --set markers immediately before the target event instead of after",
    )
    parser.add_argument(
        "--embed-html",
        metavar="HTML_PATH",
        help="Also update EMBEDDED_CAST_GZ_B64 in the given standalone HTML player file",
    )
    args = parser.parse_args()

    header, events, version = load_cast(args.input)

    mutating = bool(
        args.clear
        or args.remove
        or args.set
        or args.relabel
        or args.auto_baseline
        or args.auto_skilled
        or args.auto_comprehension
        or args.add_pattern
        or args.add_time
        or args.add_event
    )

    if args.inspect:
        inspect_range(header, events, version, args.inspect)
        if not mutating and not args.search and not args.list:
            return 0

    if args.search:
        search_events(header, events, version, args.search, context=args.context)
        if not mutating and not args.list:
            return 0

    if args.list and not mutating:
        list_markers(header, events, version)
        if args.embed_html:
            embed_cast_in_html(args.input, args.embed_html)
        return 0

    if args.clear:
        before_count = sum(1 for ev in events if len(ev) >= 2 and ev[1] == "m")
        events = [ev for ev in events if not (len(ev) >= 2 and ev[1] == "m")]
        print(f"Cleared {before_count} existing marker(s).")

    if args.remove:
        for target in args.remove:
            events, removed = remove_marker_by_target(events, target)
            if removed:
                print(f"[remove] - {', '.join(removed)}")
            else:
                print(f"[remove] WARNING: no marker matched {target!r}")

    if args.set:
        for target, where_spec, new_label in args.set:
            events, msg = set_marker_by_target(
                header,
                events,
                version,
                target,
                where_spec,
                new_label,
                insert_after=not args.before,
            )
            print(f"[set] {msg}")

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
        if args.embed_html:
            embed_cast_in_html(out_path, args.embed_html)
    elif args.embed_html:
        embed_cast_in_html(args.input, args.embed_html)
    return 0


if __name__ == "__main__":
    sys.exit(main())
