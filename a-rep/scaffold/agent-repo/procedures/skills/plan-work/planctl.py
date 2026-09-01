#!/usr/bin/env python3
"""Tiny helpers for A Rep plan-work Markdown artifacts."""

import argparse
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

ALLOWED_STATES = {
    "READY",
    "RUNNING",
    "WAIT_UNTIL",
    "WAIT_EVENT",
    "WAIT_HUMAN",
    "WAIT_GUARDIAN",
    "BLOCKED",
    "COMPLETE",
    "CANCELLED",
}
TERMINAL_STATES = {"COMPLETE", "CANCELLED"}
HEADER_FIELDS = {
    "Status",
    "Current chunk",
    "Next action",
    "Next due",
    "Waiting on",
    "Work issue",
    "Plan version",
    "Updated",
    "Last PRIMARY",
}
REQUIRED_FIELDS = {"Status", "Current chunk", "Next due", "Waiting on", "Work issue"}


class PlanError(ValueError):
    pass


def _escape(value):
    return value.replace("|", r"\|").replace("\n", " ").strip()


def _parse_due(value):
    raw = value.strip()
    if not raw or raw.lower() == "none":
        return None
    if raw.endswith("Z"):
        raw = raw[:-1] + "+00:00"
    try:
        parsed = datetime.fromisoformat(raw)
    except ValueError as exc:
        raise PlanError(
            f"invalid Next due {value!r}; use 'none' or ISO-8601 with timezone"
        ) from exc
    if parsed.tzinfo is None:
        raise PlanError(f"Next due must include a timezone: {value!r}")
    return parsed.astimezone(timezone.utc)


def _parse_plan(path):
    text = path.read_text(encoding="utf-8")
    title = ""
    fields = {}
    for line in text.splitlines():
        if line.startswith("# ") and not title:
            title = line[2:].strip()
            continue
        if line.startswith("## "):
            break
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        if key in HEADER_FIELDS:
            fields[key] = value.strip()
    if not title:
        raise PlanError(f"{path}: missing '# <plan title>'")
    missing = sorted(REQUIRED_FIELDS - fields.keys())
    if missing:
        raise PlanError(f"{path}: missing header field(s): {', '.join(missing)}")
    if fields["Status"] not in ALLOWED_STATES:
        raise PlanError(f"{path}: unknown Status {fields['Status']!r}")
    _parse_due(fields["Next due"])
    return {"id": path.parent.name, "title": title, **fields}


def _discover(root):
    plans_dir = root / "work" / "plans"
    if not plans_dir.exists():
        return []
    plans = []
    for path in sorted(plans_dir.glob("*/PLAN.md")):
        plans.append(_parse_plan(path))
    return plans


def _table(plans):
    lines = [
        "| Plan | Status | Current chunk | Next due | Waiting on | Work issue |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for plan in plans:
        lines.append(
            "| "
            + " | ".join(
                _escape(plan[key])
                for key in (
                    "title",
                    "Status",
                    "Current chunk",
                    "Next due",
                    "Waiting on",
                    "Work issue",
                )
            )
            + " |"
        )
    return "\n".join(lines)


def cmd_reindex(root, _args):
    plans = _discover(root)
    plans_dir = root / "work" / "plans"
    plans_dir.mkdir(parents=True, exist_ok=True)
    content = (
        "# Plans\n\n"
        "Generated convenience registry. Each plan's `PLAN.md` remains authoritative.\n\n"
        + _table(plans)
        + "\n"
    )
    (plans_dir / "INDEX.md").write_text(content, encoding="utf-8")
    return 0


def cmd_status(root, _args):
    print(_table(_discover(root)))
    return 0


def cmd_due(root, args):
    now = datetime.now(timezone.utc)
    horizon = now + timedelta(hours=args.within_hours)
    rows = []
    for plan in _discover(root):
        if plan["Status"] in TERMINAL_STATES:
            continue
        due = _parse_due(plan["Next due"])
        if due is None:
            continue
        if due < now:
            rows.append((plan, "OVERDUE"))
        elif due <= horizon:
            rows.append((plan, "DUE"))
    print("| Plan | Timing | Next due | Status | Current chunk | Waiting on |")
    print("| --- | --- | --- | --- | --- | --- |")
    for plan, timing in rows:
        print(
            "| "
            + " | ".join(
                _escape(value)
                for value in (
                    plan["title"],
                    timing,
                    plan["Next due"],
                    plan["Status"],
                    plan["Current chunk"],
                    plan["Waiting on"],
                )
            )
            + " |"
        )
    return 0


def build_parser():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root", type=Path, default=Path.cwd(), help="agent repository root (default: cwd)"
    )
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("reindex", help="rebuild work/plans/INDEX.md from PLAN.md files")
    sub.add_parser("status", help="print current plan state directly from PLAN.md files")
    due = sub.add_parser("due", help="print overdue and near-due nonterminal plans")
    due.add_argument(
        "--within-hours",
        type=float,
        default=24.0,
        help="treat future plans within this many hours as DUE (default: 24)",
    )
    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()
    if getattr(args, "within_hours", 0) < 0:
        parser.error("--within-hours must be non-negative")
    root = args.root.resolve()
    try:
        if args.command == "reindex":
            return cmd_reindex(root, args)
        if args.command == "status":
            return cmd_status(root, args)
        if args.command == "due":
            return cmd_due(root, args)
    except (OSError, PlanError) as exc:
        print(f"planctl: {exc}", file=sys.stderr)
        return 2
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
