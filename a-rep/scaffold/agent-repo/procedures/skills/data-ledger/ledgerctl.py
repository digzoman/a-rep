#!/usr/bin/env python3
"""Tiny helpers for A Rep data-ledger Markdown and CSV artifacts."""

import argparse
import csv
import sys
from datetime import datetime, timezone
from pathlib import Path

META_FIELDS = {
    "Authoritative business source",
    "Provider truth",
    "Local snapshot authority",
    "Record type",
    "Identity field",
    "Last synchronized",
}
REQUIRED_META = META_FIELDS
EVENT_FIELDS = [
    "timestamp",
    "event_id",
    "entity_id",
    "event_type",
    "source_id",
    "context",
    "note",
]


class LedgerError(ValueError):
    pass


def _escape(value):
    return value.replace("|", r"\|").replace("\n", " ").strip()


def _parse_readme(path):
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
        if key in META_FIELDS:
            fields[key] = value.strip()
    if not title:
        raise LedgerError(f"{path}: missing '# <ledger title>'")
    missing = sorted(REQUIRED_META - fields.keys())
    if missing:
        raise LedgerError(f"{path}: missing metadata field(s): {', '.join(missing)}")
    if not fields["Identity field"]:
        raise LedgerError(f"{path}: Identity field cannot be empty")
    return {"id": path.parent.name, "title": title, **fields}


def _count_snapshot(path):
    if not path.exists():
        return 0
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.reader(handle)
        try:
            next(reader)
        except StopIteration:
            return 0
        return sum(1 for row in reader if any(cell.strip() for cell in row))


def _discover(root):
    data_dir = root / "work" / "data"
    if not data_dir.exists():
        return []
    ledgers = []
    for path in sorted(data_dir.glob("*/README.md")):
        ledger = _parse_readme(path)
        ledger["records"] = str(_count_snapshot(path.parent / "snapshot.csv"))
        ledgers.append(ledger)
    return ledgers


def _table(ledgers):
    lines = [
        "| Ledger | Type | Records | Authority | Last sync |",
        "| --- | --- | ---: | --- | --- |",
    ]
    for ledger in ledgers:
        authority = ledger["Authoritative business source"] or ledger["Local snapshot authority"]
        lines.append(
            "| "
            + " | ".join(
                _escape(value)
                for value in (
                    ledger["title"],
                    ledger["Record type"],
                    ledger["records"],
                    authority,
                    ledger["Last synchronized"],
                )
            )
            + " |"
        )
    return "\n".join(lines)


def cmd_reindex(root, _args):
    ledgers = _discover(root)
    data_dir = root / "work" / "data"
    data_dir.mkdir(parents=True, exist_ok=True)
    content = (
        "# Data Ledgers\n\n"
        "Generated convenience registry. Each ledger's `README.md`, `snapshot.csv`, and "
        "`events.csv` remain the durable records.\n\n"
        + _table(ledgers)
        + "\n"
    )
    (data_dir / "INDEX.md").write_text(content, encoding="utf-8")
    return 0


def _ledger_dir(root, ledger_id):
    directory = root / "work" / "data" / ledger_id
    readme = directory / "README.md"
    if not readme.exists():
        raise LedgerError(f"unknown ledger {ledger_id!r}: missing {readme}")
    return directory, _parse_readme(readme)


def cmd_find(root, args):
    directory, meta = _ledger_dir(root, args.ledger_id)
    snapshot = directory / "snapshot.csv"
    if not snapshot.exists():
        raise LedgerError(f"{snapshot}: snapshot.csv does not exist")
    identity = meta["Identity field"]
    with snapshot.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames is None or identity not in reader.fieldnames:
            raise LedgerError(f"{snapshot}: missing declared identity column {identity!r}")
        matches = [row for row in reader if row.get(identity, "") == args.entity_id]
    if not matches:
        print(f"ledgerctl: entity not found: {args.entity_id}", file=sys.stderr)
        return 1
    if len(matches) > 1:
        raise LedgerError(
            f"{snapshot}: identity field {identity!r} is not unique for {args.entity_id!r}"
        )
    writer = csv.DictWriter(sys.stdout, fieldnames=reader.fieldnames, lineterminator="\n")
    writer.writeheader()
    writer.writerow(matches[0])
    return 0


def _read_events(path):
    if not path.exists():
        return []
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != EVENT_FIELDS:
            raise LedgerError(
                f"{path}: expected event columns {','.join(EVENT_FIELDS)}; got "
                f"{','.join(reader.fieldnames or [])}"
            )
        return list(reader)


def cmd_append_event(root, args):
    directory, _meta = _ledger_dir(root, args.ledger_id)
    if not args.event_id.strip():
        raise LedgerError("event_id cannot be empty")
    path = directory / "events.csv"
    existing = _read_events(path)
    comparable = {
        "entity_id": args.entity_id,
        "event_type": args.event_type,
        "source_id": args.source_id,
    }
    for row in existing:
        if row["event_id"] != args.event_id:
            continue
        if all(row[key] == value for key, value in comparable.items()):
            print(f"event already present: {args.event_id}")
            return 0
        raise LedgerError(
            f"event_id {args.event_id!r} already exists with different entity/type/source"
        )
    timestamp = args.timestamp or datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    row = {
        "timestamp": timestamp,
        "event_id": args.event_id,
        "entity_id": args.entity_id,
        "event_type": args.event_type,
        "source_id": args.source_id,
        "context": args.context,
        "note": args.note,
    }
    new_file = not path.exists()
    with path.open("a", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=EVENT_FIELDS, lineterminator="\n")
        if new_file:
            writer.writeheader()
        writer.writerow(row)
    print(f"event appended: {args.event_id}")
    return 0


def build_parser():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root", type=Path, default=Path.cwd(), help="agent repository root (default: cwd)"
    )
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("reindex", help="rebuild work/data/INDEX.md from ledger README files")

    find = sub.add_parser("find", help="find one snapshot row by the ledger's identity field")
    find.add_argument("ledger_id")
    find.add_argument("entity_id")

    event = sub.add_parser("append-event", help="append one idempotent logical event")
    event.add_argument("ledger_id")
    event.add_argument("event_id")
    event.add_argument("entity_id")
    event.add_argument("event_type")
    event.add_argument("--timestamp", default="")
    event.add_argument("--source-id", default="")
    event.add_argument("--context", default="")
    event.add_argument("--note", default="")
    return parser


def main():
    args = build_parser().parse_args()
    root = args.root.resolve()
    try:
        if args.command == "reindex":
            return cmd_reindex(root, args)
        if args.command == "find":
            return cmd_find(root, args)
        if args.command == "append-event":
            return cmd_append_event(root, args)
    except (OSError, csv.Error, LedgerError) as exc:
        print(f"ledgerctl: {exc}", file=sys.stderr)
        return 2
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
