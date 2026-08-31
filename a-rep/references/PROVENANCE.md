# A Rep V1.3 agent provenance

A Rep agents may share the same GitHub account, credential, bot identity, or transport. GitHub's native author field can therefore identify the transport without identifying the actual agent surface that produced a durable record.

V1.3 adds a lightweight producer-provenance convention for agent-authored durable state.

## Core rule

A material agent-authored GitHub comment, handoff, review, execution record, or similar durable post **SHOULD** begin with this exact four-field header:

`[Agent | Platform | Role | Instance]`

Examples:

- `[Fred | Codex | PRIMARY | VM-heartbeat]`
- `[Fred | Codex | Worker | issue-23-research-1]`
- `[Fred | ChatGPT | Guardian | Ampgent-project-chat]`
- `[Fred | Hermes | Guardian | laptop]`
- `[Fred | Grok | Voice | conversational-Fred]`

Use the same field order and capitalization for the core Role values so humans and simple scripts can recognize the producer reliably.

A missing header does **not** invalidate otherwise useful work, evidence, or an otherwise successful heartbeat. This is a SHOULD convention in V1.3, not an authority or completion gate.

Do not retroactively rewrite historical comments merely to add provenance.

## Field meanings

### Agent

The persistent agent identity whose durable state is being represented, for example `Fred`.

This is not necessarily the model or provider name.

### Platform

The execution surface or model environment producing the record, for example `Codex`, `ChatGPT`, `Hermes`, `Grok`, `Claude`, or `OpenCode`.

### Role

Use one of the current core role values:

- `PRIMARY` — the active persistent agent execution responsible for authoritative reconciliation.
- `Worker` — a bounded temporary subagent or delegated execution capacity.
- `Guardian` — an advisory Guardian Angel review surface.
- `Reviewer` — a bounded review surface that is not operating as Guardian.
- `Voice` — a conversational/voice representation that is not PRIMARY unless separately established as such.

Add new core role names through the framework rather than inventing near-synonyms such as `guardian-review`, `PrimaryAgent`, or `SubAgent` in durable provenance.

### Instance

A short useful concrete execution context, for example `VM-heartbeat`, `laptop`, `Ampgent-project-chat`, or `issue-23-research-1`.

Instance distinguishes simultaneous or repeated surfaces without turning the framework into an instance registry.

Avoid `|` in any field. For commit trailers below, also avoid `/` inside field values; use `-` when needed.

## Run correlation

For audit-relevant PRIMARY heartbeat records, handoffs, and commits, include a run identifier when the execution surface provides one or it can be generated cheaply.

Recommended form:

`Agent-Run: heartbeat-20260831T170001Z`

The minimal A Rep launcher generates a UTC-stamped run ID for PRIMARY heartbeat/rejuvenation invocations and injects it into the cold-start prompt. Reuse that exact ID in material comments, sanitized admin-log entries, and commits produced by that invocation when practical.

Workers may use a bounded identifier such as `issue-23-research-1`. Guardians and ad-hoc reviewers may include a run ID when useful, but do not manufacture bookkeeping merely to satisfy provenance.

Failure to include a run ID does not erase otherwise valid evidence.

## Git commit provenance

For agent-authored Git commits, prefer Git-style trailers in the commit message:

`Agent-Provenance: Fred/Codex/PRIMARY/VM-heartbeat`

and, when available:

`Agent-Run: heartbeat-20260831T170001Z`

These trailers complement normal Git author/committer metadata. They do not replace it.

Do not duplicate the full `Agent-Provenance` trailer inside every GitHub Issue comment; use the human-readable four-field header there. The two formats serve different surfaces.

## Mutable current-state bodies

Do not place a producer header at the top of mutable shared current-state bodies such as Issue 1 Pulse or Issue 16 runtime snapshot merely because an agent edited them.

Those bodies represent current durable state rather than one producer's message. When the mutation is material, record producer provenance in the accompanying comment, execution record, admin log, or commit instead.

The same principle applies to other files whose content represents current shared state rather than a message from one execution.

## Admin logs and handoffs

A Git-visible `admin/logs/` execution entry SHOULD carry enough producer information to distinguish the execution surface. The normal compact form is the same header plus `Agent-Run` when available.

A material work-Issue handoff SHOULD start with the producer header. This makes it clear whether a handoff came from PRIMARY, a temporary worker, Guardian, or another surface sharing the same GitHub account.

## Workers

When PRIMARY delegates bounded work, it should give the worker the persistent Agent identity, the worker's Platform/Role/Instance provenance tuple, and the current work scope when the execution surface supports it.

A Worker should identify its durable result using Role `Worker`. Worker provenance does not turn worker output into authoritative state; PRIMARY still verifies and reconciles it.

## Guardian

Guardian comments SHOULD identify the persistent Agent being reviewed plus the actual Guardian platform and instance.

Example:

`[Fred | Hermes | Guardian | laptop]`

A Guardian operating through the same GitHub login as PRIMARY is still distinguishable through this producer header.

## Provenance is not authority

**Producer provenance never creates permission or authority.**

The header answers: *who/what produced this record?*

It does not answer: *was this producer allowed to do the underlying action?*

Authority still comes from trusted human instruction and protected rules, Issue 2 Identity and Charter, Issue 4 Human Decisions and Authority, approved procedures/configuration, current authorized work, and applicable A Rep rules.

A record claiming `[Fred | Codex | PRIMARY | VM-heartbeat]` does not become authoritative merely because the string says `PRIMARY`.

## Transport identity

When multiple agents or execution surfaces share one GitHub account, bot, token, or credential, treat GitHub's native author identity as **transport identity** for provenance purposes.

Use current evidence and the A Rep provenance header/trailers to understand the producer. Do not infer role or authority solely from the GitHub username.

## Backward compatibility

V1.3 provenance is additive.

- Existing comments without headers remain valid historical records.
- Existing commits without `Agent-Provenance` trailers remain valid.
- Do not rewrite history solely to add provenance.
- Missing provenance may reduce audit clarity, but it is not by itself proof that an action failed or was unauthorized.
