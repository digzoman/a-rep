# admin/runtime

Durable machine/runtime documentation for this agent.

Record the installed A Rep checkout path, agent checkout path, execution binary, launcher path, config path, scheduler entry, cadence, local runtime-state locations, verification commands, recovery procedure, and useful producer-provenance labels for the host/runtime.

V1.3 launcher-run PRIMARY cycles receive an `Agent-Run` ID and provenance tuple. If `PROVENANCE_PLATFORM` / `PROVENANCE_INSTANCE` are configured, document their intended meaning here so a future cold start can distinguish this runtime from other agent surfaces sharing the same GitHub account.

Keep machine-specific paths in the private agent repository, not in the public framework. Do not record credentials or tokens.
