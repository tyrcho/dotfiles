#!/usr/bin/env python3
"""Search past Claude Code sessions and print `claude --resume` commands.

Walks ~/.claude/projects/*/*.jsonl. No external dependencies.
"""

from __future__ import annotations

import argparse
import json
import logging
import math
import os
import re
import sys
from collections import Counter
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Iterable

logging.basicConfig(level=logging.INFO, format="%(message)s")
log = logging.getLogger("find-session")

PROJECTS_DIR = Path.home() / ".claude" / "projects"
FILE_PATH_KEYS = ("file_path", "filePath", "path", "notebook_path")
OBSERVER_SUBSTR = "claude-mem-observer-sessions"


def main() -> int:
    args = parse_args()
    since, until = parse_date_window(args.since, args.until)
    candidates = collect_candidates(args, since, until)
    tokens = [t for t in args.query.lower().split() if t] if args.query else []
    scanned = [m for m in (search_session(p, args, tokens) for p in candidates) if m]
    matches = rank_matches(scanned, tokens, corpus_size=len(candidates))
    matches = matches[: args.limit]
    if not matches:
        log.info("No sessions matched.")
        return 1
    print(format_report(matches, args))
    return 0


def rank_matches(scanned: list["SessionMatch"], tokens: list[str], corpus_size: int) -> list["SessionMatch"]:
    if not tokens:
        scanned.sort(key=lambda m: (m.path_hits, m.total_hits, m.mtime), reverse=True)
        return scanned
    df: Counter = Counter()
    for m in scanned:
        for t in m.token_freq:
            df[t] += 1
    matches = [m for m in scanned if all(m.token_freq.get(t, 0) > 0 for t in tokens)]
    for m in matches:
        m.score = sum(
            (1 + math.log(m.token_freq[t])) * math.log(corpus_size / df[t])
            for t in tokens
            if df[t] > 0
        )
    matches.sort(key=lambda m: (m.score, m.path_hits, m.total_hits, m.mtime), reverse=True)
    return matches


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("query", nargs="?", help="case-insensitive substring (any message)")
    p.add_argument("--path", help="substring to match against tool-call file paths")
    p.add_argument("--since", help="ISO date, 'yesterday', 'today', or 'Nd'")
    p.add_argument("--until", help="ISO date, 'yesterday', 'today', or 'Nd'")
    p.add_argument("--project", help="substring filter on decoded project name")
    p.add_argument("--limit", type=int, default=10)
    p.add_argument("--include-active", action="store_true", help="don't skip the current $CLAUDE_CODE_SESSION_ID")
    p.add_argument("--include-observer", action="store_true", help="don't skip claude-mem observer-sessions")
    args = p.parse_args()
    if not args.query and not args.path:
        p.error("provide a QUERY, --path, or both")
    return args


def parse_date_window(since: str | None, until: str | None) -> tuple[datetime | None, datetime | None]:
    start = parse_date(since, end_of_day=False) if since else None
    end = parse_date(until, end_of_day=True) if until else None
    return start, end


def parse_date(value: str, end_of_day: bool) -> datetime:
    now = datetime.now(timezone.utc).astimezone()
    today = now.replace(hour=0, minute=0, second=0, microsecond=0)
    if value == "today":
        base = today
    elif value == "yesterday":
        base = today - timedelta(days=1)
    elif re.fullmatch(r"\d+d", value):
        base = today - timedelta(days=int(value[:-1]))
    else:
        try:
            base = datetime.fromisoformat(value).replace(tzinfo=now.tzinfo)
        except ValueError as exc:
            raise SystemExit(f"bad date {value!r}: {exc}") from exc
    if end_of_day:
        base = base.replace(hour=23, minute=59, second=59, microsecond=999_999)
    return base


def collect_candidates(args: argparse.Namespace, since: datetime | None, until: datetime | None) -> list[Path]:
    if not PROJECTS_DIR.exists():
        raise SystemExit(f"no projects dir at {PROJECTS_DIR}")
    active = None if args.include_active else os.environ.get("CLAUDE_CODE_SESSION_ID")
    found: list[Path] = []
    for project_dir in PROJECTS_DIR.iterdir():
        if not project_dir.is_dir():
            continue
        if not args.include_observer and OBSERVER_SUBSTR in project_dir.name:
            continue
        if args.project and not project_matches(project_dir.name, args.project):
            continue
        for jsonl in project_dir.glob("*.jsonl"):
            if jsonl.name.startswith("agent-"):
                continue
            if active and jsonl.stem == active:
                continue
            mtime = datetime.fromtimestamp(jsonl.stat().st_mtime).astimezone()
            if since and mtime < since:
                continue
            if until and mtime > until:
                continue
            found.append(jsonl)
    log.info(f"Scanning {len(found)} session file(s)...")
    return found


def decode_project(folder_name: str) -> str:
    return folder_name.replace("-", "/")


def project_matches(folder_name: str, needle: str) -> bool:
    needle = needle.lower()
    return needle in folder_name.lower() or needle in decode_project(folder_name).lower()


@dataclass
class SessionMatch:
    session_id: str
    project_folder: str
    cwd: str | None
    start_ts: str | None
    mtime: float
    path_hits: int
    total_hits: int
    file_counts: Counter = field(default_factory=Counter)
    topic: str | None = None
    snippet: str | None = None
    token_freq: Counter = field(default_factory=Counter)
    score: float = 0.0


def search_session(jsonl: Path, args: argparse.Namespace, tokens: list[str]) -> SessionMatch | None:
    path_query = args.path.lower() if args.path else None
    total = 0
    path_hits = 0
    file_counts: Counter = Counter()
    token_freq: Counter = Counter()
    cwd: str | None = None
    start_ts: str | None = None
    topic: str | None = None
    best_text: str | None = None
    best_hits: list[str] = []
    best_score = (0, 0)
    for entry in iter_entries(jsonl):
        if cwd is None and isinstance(entry.get("cwd"), str):
            cwd = entry["cwd"]
        if start_ts is None and entry.get("type") == "user":
            start_ts = entry.get("timestamp")
        text, paths = extract_searchable(entry)
        if topic is None and entry.get("type") == "user":
            topic = extract_topic(text)
        if tokens:
            text_lower = text.lower()
            entry_hits = {t: text_lower.count(t) for t in tokens}
            entry_hits = {t: c for t, c in entry_hits.items() if c > 0}
            if entry_hits:
                total += 1
                token_freq.update(entry_hits)
                score = (len(entry_hits), sum(entry_hits.values()))
                if score > best_score:
                    best_score = score
                    best_text = text
                    best_hits = list(entry_hits.keys())
        for p in paths:
            p_lower = p.lower()
            if path_query and path_query in p_lower:
                path_hits += 1
                file_counts[p] += 1
            if tokens and not path_query:
                p_hits = {t: p_lower.count(t) for t in tokens}
                p_hits = {t: c for t, c in p_hits.items() if c > 0}
                if p_hits:
                    total += 1
                    token_freq.update(p_hits)
    if path_hits == 0 and total == 0:
        return None
    snippet = make_cluster_snippet(best_text, best_hits) if best_text else None
    return SessionMatch(
        session_id=jsonl.stem,
        project_folder=jsonl.parent.name,
        cwd=cwd,
        start_ts=start_ts,
        mtime=jsonl.stat().st_mtime,
        path_hits=path_hits,
        total_hits=total + path_hits,
        file_counts=file_counts,
        topic=topic,
        snippet=snippet,
        token_freq=token_freq,
    )


def extract_topic(text: str) -> str | None:
    """Pull a usable session-title from the first user message text."""
    if not text:
        return None
    args_match = re.search(r"<command-args>(.*?)</command-args>", text, re.DOTALL)
    if args_match:
        candidate = re.sub(r"\s+", " ", args_match.group(1)).strip()
        if candidate:
            return clip(candidate, 120)
    stripped = re.sub(r"<command-[^>]+>.*?</command-[^>]+>", "", text, flags=re.DOTALL)
    stripped = re.sub(r"<local-command-stdout>.*?</local-command-stdout>", "", stripped, flags=re.DOTALL)
    stripped = re.sub(r"<system-reminder>.*?</system-reminder>", "", stripped, flags=re.DOTALL)
    stripped = re.sub(r"\s+", " ", stripped).strip()
    return clip(stripped, 120) if stripped else None


def make_snippet(text: str, query: str, width: int = 40) -> str | None:
    idx = text.lower().find(query.lower())
    if idx < 0:
        return None
    return snippet_window(text, idx, idx + len(query), pad=width)


def make_cluster_snippet(text: str, tokens: list[str], pad: int = 25, max_width: int = 200) -> str | None:
    """Pick the tightest window covering all listed tokens; fall back to first occurrence."""
    if not text or not tokens:
        return None
    text_lower = text.lower()
    positions: list[tuple[int, int, str]] = []
    for t in tokens:
        i = 0
        while True:
            j = text_lower.find(t, i)
            if j < 0:
                break
            positions.append((j, j + len(t), t))
            i = j + 1
    if not positions:
        return None
    positions.sort()
    present = {t for _, _, t in positions}
    best: tuple[int, int, int] | None = None  # (length, start, end)
    counts: Counter = Counter()
    left = 0
    for right, (_, _, tok_r) in enumerate(positions):
        counts[tok_r] += 1
        while len(counts) == len(present) and counts[positions[left][2]] > 1:
            counts[positions[left][2]] -= 1
            left += 1
        if len(counts) == len(present):
            start_pos = positions[left][0]
            end_pos = positions[right][1]
            window = end_pos - start_pos
            if window <= max_width and (best is None or window < best[0]):
                best = (window, start_pos, end_pos)
    if best is None:
        start_pos, end_pos, _ = positions[0]
        return snippet_window(text, start_pos, end_pos, pad=pad)
    _, start_pos, end_pos = best
    return snippet_window(text, start_pos, end_pos, pad=pad)


def snippet_window(text: str, start: int, end: int, pad: int) -> str:
    s = max(0, start - pad)
    e = min(len(text), end + pad)
    body = re.sub(r"\s+", " ", text[s:e]).strip()
    if not body:
        return ""
    prefix = "…" if s > 0 else ""
    suffix = "…" if e < len(text) else ""
    return f"{prefix}{body}{suffix}"


def clip(text: str, limit: int) -> str:
    return text if len(text) <= limit else text[: limit - 1].rstrip() + "…"


def iter_entries(jsonl: Path) -> Iterable[dict]:
    with jsonl.open("r", encoding="utf-8", errors="replace") as f:
        for lineno, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError as exc:
                log.warning(f"{jsonl.name}:{lineno}: skipped malformed line ({exc})")


def extract_searchable(entry: dict) -> tuple[str, list[str]]:
    message = entry.get("message") or entry
    content = message.get("content") if isinstance(message, dict) else None
    if content is None and entry.get("type") in {"user", "assistant"}:
        content = entry.get("content")
    text_chunks: list[str] = []
    paths: list[str] = []
    walk_content(content, text_chunks, paths)
    return "\n".join(text_chunks), paths


def walk_content(node, text_chunks: list[str], paths: list[str]) -> None:
    if node is None:
        return
    if isinstance(node, str):
        text_chunks.append(node)
        return
    if isinstance(node, list):
        for item in node:
            walk_content(item, text_chunks, paths)
        return
    if isinstance(node, dict):
        kind = node.get("type")
        if kind == "text" and isinstance(node.get("text"), str):
            text_chunks.append(node["text"])
        if kind == "tool_use":
            walk_tool_input(node.get("input"), text_chunks, paths)
        if kind == "tool_result":
            walk_content(node.get("content"), text_chunks, paths)


def walk_tool_input(node, text_chunks: list[str], paths: list[str]) -> None:
    if isinstance(node, str):
        text_chunks.append(node)
        return
    if isinstance(node, list):
        for item in node:
            walk_tool_input(item, text_chunks, paths)
        return
    if isinstance(node, dict):
        for key, value in node.items():
            if key in FILE_PATH_KEYS and isinstance(value, str):
                paths.append(value)
                text_chunks.append(value)
            elif isinstance(value, (dict, list)):
                walk_tool_input(value, text_chunks, paths)
            elif isinstance(value, str):
                text_chunks.append(value)


def format_report(matches: list[SessionMatch], args: argparse.Namespace) -> str:
    header = describe_query(args, len(matches))
    blocks = [render_match(i + 1, m) for i, m in enumerate(matches)]
    return header + "\n\n" + "\n\n".join(blocks)


def describe_query(args: argparse.Namespace, n: int) -> str:
    bits = []
    if args.query:
        bits.append(f'"{args.query}"')
    if args.path:
        bits.append(f"path~{args.path}")
    if args.since:
        bits.append(f"since {args.since}")
    if args.until:
        bits.append(f"until {args.until}")
    return f"{n} session(s) matched {' '.join(bits)}:"


def render_match(rank: int, m: SessionMatch) -> str:
    cwd = m.cwd or decode_project(m.project_folder)
    timespan = format_timespan(parse_iso(m.start_ts), datetime.fromtimestamp(m.mtime).astimezone())
    hits = format_hits(m)
    top = ", ".join(f"{p} ({c})" for p, c in m.file_counts.most_common(3))
    resume = f'cd "{cwd}" && claude --resume {m.session_id}'
    lines = [f"{rank}. {timespan} · {hits}"]
    if m.topic:
        lines.append(f"   Topic: {m.topic}")
    if m.snippet:
        lines.append(f"   Match: {m.snippet}")
    if top:
        lines.append(f"   Files: {top}")
    lines.append(f"   {resume}")
    return "\n".join(lines)


def parse_iso(ts: str | None) -> datetime | None:
    if not ts:
        return None
    try:
        return datetime.fromisoformat(ts.replace("Z", "+00:00")).astimezone()
    except ValueError:
        return None


def format_timespan(start: datetime | None, last: datetime) -> str:
    last_str = last.strftime("%Y-%m-%d %H:%M %Z").strip()
    if start is None:
        return f"last {last_str}"
    start_str = start.strftime("%Y-%m-%d %H:%M %Z").strip()
    if start.date() == last.date():
        return f"{start_str} → {last.strftime('%H:%M')}"
    return f"{start_str} → {last_str}"


def format_hits(m: SessionMatch) -> str:
    body = m.total_hits - m.path_hits
    parts = []
    if m.path_hits:
        parts.append(f"matched {m.path_hits} file path{'s' if m.path_hits != 1 else ''}")
    if body:
        parts.append(f"matched {body} message{'s' if body != 1 else ''}")
    return " · ".join(parts) if parts else f"{m.total_hits} hits"


if __name__ == "__main__":
    sys.exit(main())
