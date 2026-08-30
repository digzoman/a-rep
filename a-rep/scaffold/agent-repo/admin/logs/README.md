# admin/logs

Tracked, sanitized operational logs for executed A Rep cycles.

Prefer one Markdown file per day, for example `2026-08-30.md`. Record concise facts such as timestamp, cycle type, Issue focus, result, evidence pointer, next step, and errors.

Do not copy raw Codex/OpenCode output here. Raw execution output belongs in Git-ignored `.arep/raw-logs/`.

Do not log five-minute scheduler polls that exit because a heartbeat is not due. Issue 3 remains the cross-cutting trail for material transitions rather than routine cycle detail.

Never commit secrets or unnecessarily sensitive external-system data.
