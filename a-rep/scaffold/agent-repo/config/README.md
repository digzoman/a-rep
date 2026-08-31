# config

Non-secret configuration and durable strategic context for the persistent agent.

`arep.env` is the runtime configuration. It may contain machine paths, cadence, execution-driver selection, local runtime-state paths, and optional non-secret producer labels such as `PROVENANCE_PLATFORM` / `PROVENANCE_INSTANCE`.

The launcher falls back to the execution driver as Platform and `runtime-heartbeat` / `runtime-rejuvenation` as Instance when those provenance labels are empty or absent. They are labels for producer traceability, not authority settings.

`agent-context.md` is the short hot context. PRIMARY and Guardian read it on every cycle. Keep it concise and current: role summary, mission, cross-cutting priorities, decision principles, and only the context worth paying to load every wake.

`agent-context-deep.md` is richer cold context. Do not load it automatically during baseline recovery. First recover hot/current work state; load deep only when the selected task/recovery need materially benefits from background absent from hot context or hot context points to relevant deep material.

Issue 2 remains authoritative for durable identity/charter and Issue 4 for human authority decisions. Context files and provenance labels help reasoning/traceability; they do not create permission.

Do not store credentials, API keys, tokens, passwords, or other secrets here.
