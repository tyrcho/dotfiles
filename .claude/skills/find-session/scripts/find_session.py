#!/usr/bin/env python3
"""Search past Claude Code sessions and print `claude --resume` commands.

Scans a static allowlist of project folders under ~/.claude/projects/. No external dependencies.
"""

from __future__ import annotations

import argparse
import fnmatch
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
from typing import Iterable, NamedTuple

logging.basicConfig(level=logging.INFO, format="%(message)s")
log = logging.getLogger("find-session")

PROJECTS_DIR = Path.home() / ".claude" / "projects"
FILE_PATH_KEYS = ("filePath", "file_path", "notebook_path", "path")
# Static allowlist: scan only projects launched from ~ (encoded `-Users-michel-daviot*`),
# excluding claude-mem's observer-sessions (its transcripts ingest every other session
# and swamp searches). Drops ephemeral cwds like `-private-tmp*` and the bare `-` (root).
PROJECT_INCLUDE_GLOB = "-Users-michel-daviot*"
PROJECT_EXCLUDE_GLOB = "*--claude-mem-*"


def main() -> int:
    args = parse_args()
    since, until = parse_date_window(args.since, args.until)
    candidates = collect_candidates(args, since, until)
    tokens = [t for t in args.query.lower().split() if t]
    scanned = [m for m in (search_session(p, tokens) for p in candidates) if m]
    matches = rank_matches(scanned, tokens, corpus_size=len(candidates))
    matches = matches[: args.limit]
    if not matches:
        log.info("No sessions matched.")
        return 1
    print(format_report(matches, args))
    return 0


def rank_matches(scanned: list["SessionMatch"], tokens: list[str], corpus_size: int) -> list["SessionMatch"]:
    df: Counter = Counter()
    for m in scanned:
        for t in m.token_freq:
            df[t] += 1
    matches = [m for m in scanned if all(m.token_freq.get(t, 0) > 0 for t in tokens)]
    scores = {id(m): _tf_idf_score(m, tokens, df, corpus_size) for m in matches}
    matches.sort(key=lambda m: (scores[id(m)], m.entry_hits, m.mtime), reverse=True)
    return matches


def _tf_idf_score(m: "SessionMatch", tokens: list[str], df: Counter, corpus_size: int) -> float:
    return sum(
        (1 + math.log(m.token_freq[t])) * math.log(corpus_size / df[t])
        for t in tokens
        if df[t] > 0
    )


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("query", help="space-separated tokens; all must appear (in any order)")
    p.add_argument("--since", help="ISO date, 'yesterday', 'today', or 'Nd'")
    p.add_argument("--until", help="ISO date, 'yesterday', 'today', or 'Nd'")
    p.add_argument("--project", help="substring filter on decoded project name")
    p.add_argument("--limit", type=int, default=10)
    p.add_argument("--include-active", action="store_true", help="don't skip the current $CLAUDE_CODE_SESSION_ID")
    return p.parse_args()


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
    for project_dir in PROJECTS_DIR.glob(PROJECT_INCLUDE_GLOB):
        if not project_dir.is_dir():
            continue
        if fnmatch.fnmatch(project_dir.name, PROJECT_EXCLUDE_GLOB):
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


@dataclass(frozen=True)
class SessionMatch:
    session_id: str
    project_folder: str
    cwd: str | None
    start_ts: str | None
    mtime: float
    entry_hits: int
    total_entries: int
    file_counts: Counter = field(default_factory=Counter)
    topic: str | None = None
    snippet: str | None = None
    token_freq: Counter = field(default_factory=Counter)


def search_session(jsonl: Path, tokens: list[str]) -> SessionMatch | None:
    scanner = _SessionScanner(tokens=tokens)
    for entry in iter_entries(jsonl):
        scanner.scan(entry)
    if scanner.entry_hits == 0:
        return None
    snippet = make_cluster_snippet(scanner.best_text, scanner.best_hits) if scanner.best_text else None
    return SessionMatch(
        session_id=jsonl.stem,
        project_folder=jsonl.parent.name,
        cwd=scanner.cwd,
        start_ts=scanner.start_ts,
        mtime=jsonl.stat().st_mtime,
        entry_hits=scanner.entry_hits,
        total_entries=scanner.total_entries,
        file_counts=scanner.file_counts,
        topic=scanner.topic,
        snippet=snippet,
        token_freq=scanner.token_freq,
    )


@dataclass
class _SessionScanner:
    tokens: list[str]
    total_entries: int = 0
    entry_hits: int = 0
    file_counts: Counter = field(default_factory=Counter)
    token_freq: Counter = field(default_factory=Counter)
    cwd: str | None = None
    start_ts: str | None = None
    topic: str | None = None
    best_text: str | None = None
    best_hits: list[str] = field(default_factory=list)
    best_score: tuple[int, int] = (0, 0)

    def scan(self, entry: dict) -> None:
        self.total_entries += 1
        self._observe_metadata(entry)
        text, paths = extract_searchable(entry)
        if self.topic is None and entry.get("type") == "user":
            self.topic = extract_topic(text)
        self._score_text(text)
        self._count_paths(paths)

    def _observe_metadata(self, entry: dict) -> None:
        if self.cwd is None and isinstance(entry.get("cwd"), str):
            self.cwd = entry["cwd"]
        if self.start_ts is None and entry.get("type") == "user":
            self.start_ts = entry.get("timestamp")

    def _score_text(self, text: str) -> None:
        text_lower = text.lower()
        hits = {t: text_lower.count(t) for t in self.tokens}
        hits = {t: c for t, c in hits.items() if c > 0}
        if not hits:
            return
        self.entry_hits += 1
        self.token_freq.update(hits)
        score = (len(hits), sum(hits.values()))
        if score > self.best_score:
            self.best_score = score
            self.best_text = text
            self.best_hits = list(hits.keys())

    def _count_paths(self, paths: list[str]) -> None:
        for p in paths:
            if any(t in p.lower() for t in self.tokens):
                self.file_counts[p] += 1


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


class _Pos(NamedTuple):
    start: int
    end: int
    token: str


class _Window(NamedTuple):
    length: int
    start: int
    end: int


def make_cluster_snippet(text: str, tokens: list[str], pad: int = 25, max_width: int = 200) -> str | None:
    """Pick the tightest window covering all listed tokens; fall back to first occurrence."""
    if not text or not tokens:
        return None
    positions = _all_token_positions(text.lower(), tokens)
    if not positions:
        return None
    best = _tightest_cover(positions, max_width)
    if best is None:
        first = positions[0]
        return snippet_window(text, first.start, first.end, pad=pad)
    return snippet_window(text, best.start, best.end, pad=pad)


def _all_token_positions(text_lower: str, tokens: list[str]) -> list[_Pos]:
    positions: list[_Pos] = []
    for t in tokens:
        i = 0
        while True:
            j = text_lower.find(t, i)
            if j < 0:
                break
            positions.append(_Pos(j, j + len(t), t))
            i = j + 1
    positions.sort()
    return positions


def _tightest_cover(positions: list[_Pos], max_width: int) -> _Window | None:
    present = {p.token for p in positions}
    best: _Window | None = None
    counts: Counter = Counter()
    left = 0
    for right, p in enumerate(positions):
        counts[p.token] += 1
        while len(counts) == len(present) and counts[positions[left].token] > 1:
            counts[positions[left].token] -= 1
            left += 1
        if len(counts) == len(present):
            start = positions[left].start
            end = positions[right].end
            length = end - start
            if length <= max_width and (best is None or length < best.length):
                best = _Window(length, start, end)
    return best


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
    bits = [f'"{args.query}"']
    if args.since:
        bits.append(f"since {args.since}")
    if args.until:
        bits.append(f"until {args.until}")
    return f"{n} session(s) matched {' '.join(bits)}:"


def render_match(rank: int, m: SessionMatch) -> str:
    cwd = m.cwd or decode_project(m.project_folder)
    timespan = format_timespan(parse_iso(m.start_ts), datetime.fromtimestamp(m.mtime).astimezone())
    hits = f"{m.entry_hits}/{m.total_entries} entr{'ies' if m.total_entries != 1 else 'y'}"
    top = ", ".join(f"{p} ({c})" for p, c in m.file_counts.most_common(3))
    resume = f'cd "{cwd}" && claude --resume {m.session_id}'
    lines = [f"{rank}. {timespan} · matched {hits}"]
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


if __name__ == "__main__":
    sys.exit(main())
