# admin/logs

Tracked, sanitized operational logs for executed A Rep cycles.

Prefer one Markdown file per day, for example `2026-08-30.md`. Record concise facts such as producer provenance, `Agent-Run` when available, timestamp, cycle type, Issue focus, result, evidence pointer, next step, and errors.

For launcher-run PRIMARY cycles, a useful entry begins with the exact producer tuple/run ID supplied by the runtime, for example:

```text
[Fred | Codex | PRIMARY | VM-heartbeat]
Agent-Run: heartbeat-20260831T170001Z
```

This makes Git-visible cycle records correlatable with Issue comments, commits, and `.arep/raw-logs/` without a separate run registry.

Do not copy raw Codex/OpenCode output here. Raw execution output belongs in Git-ignored `.arep/raw-logs/`.

Do not log scheduler polls that exit because a heartbeat is not due. Issue 3 remains the cross-cutting trail for material transitions rather than routine cycle detail.

Producer provenance does not create authority or prove success.

Never commit secrets or unnecessarily sensitive external-system data.
