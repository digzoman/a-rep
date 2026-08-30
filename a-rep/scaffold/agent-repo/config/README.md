# config

Non-secret configuration and durable strategic context for the persistent agent.

`arep.env` is the runtime configuration. It may contain machine paths, cadence, execution-driver selection, and local runtime-state paths.

`agent-context.md` is the short hot context. PRIMARY and Guardian read it on every cycle. Keep it concise and current: role summary, mission, cross-cutting priorities, decision principles, and only the context worth paying to load every wake.

`agent-context-deep.md` is richer cold context. Load it on demand when the short context points to it, active work is unclear, or deeper organizational/strategic background materially improves the task.

Issue 2 remains authoritative for durable identity/charter and Issue 4 for human authority decisions. Context files help reasoning; they do not create permission.

Do not store credentials, API keys, tokens, passwords, or other secrets here.
