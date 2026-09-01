# A Rep

A Rep is a lightweight, nondeterministic-first Repeating Agent Framework.

Its purpose is to let a capable coding agent operate as a persistent, goal-seeking, self-improving agent by following one portable skill and using a private Git repository plus current external evidence as durable operating state.

A Rep does not require a dedicated orchestration platform. In V1, the coding agent is the execution engine, the skill is the operating protocol, the agent repository is durable control/context/memory state, and tiny deterministic schedulers provide wakeups.

## V1 thesis

A PRIMARY repeatedly reconstructs reality, reads concise strategic context, selects the highest-value eligible action, acts, verifies the result, records durable state, leaves a fresh-session handoff when needed, learns, and repeats.

A Rep begins with judgment rather than a predetermined workflow. Stable recurring behaviour may later be formalized into reviewed procedures, scripts, skills, or graph-based workflows.

## V1.4: event wake + backup heartbeat

V1.4 separates **responsiveness** from **recovery** without adding an orchestration service.

A tiny GitHub watcher may poll the private agent repository every minute. If nothing meaningful changed, it exits without launching the model. If it sees a new Issue, reopened Issue, or non-self Issue comment, it requests an immediate `event` PRIMARY wake through the same local PRIMARY lease used by heartbeat/rejuvenation.

Separately, the normal heartbeat remains a recovery/liveness fallback. The recommended/default normal backup interval for an active agent is now **30 minutes**; the heartbeat cron may still poll every five minutes so explicit fast/deadline mode can take effect quickly.

A successful event wake postpones the next backup heartbeat, avoiding an immediate redundant model invocation.

If PRIMARY knows authorized scheduled work needs another wake sooner than the normal 30-minute backup, it should explicitly enter fast mode or `DEADLINE_MODE=true` early enough to meet the window, then restore normal state when appropriate. V1.4 does not parse Issue prose or automatically infer deadlines.

This remains deliberately small: no database, queue, webhook service, activity score, day/night scheduler, or second PRIMARY.

See `a-rep/references/EVENT_WAKE.md` and `a-rep/references/RUNTIME.md`.

## V1.4.1: provenance-preserving human notifications

V1.4.1 makes asynchronous human notification a first-class A Rep concern without introducing a notification service.

Material phone pushes, Discord messages, emails, or similar alerts SHOULD reuse the same provenance header already used in GitHub:

`[Agent | Platform | Role | Instance]`

For transports with a title/subject, that visible title SHOULD be an exact provenance header.

If one A Rep surface originates the message and another surface relays it, preserve the origin header as the title and add a `Relayed-By: [Agent | Platform | Role | Instance]` line for the delivery surface.

A notification gets human attention; it does not itself create approval or authority.

A Rep does not mandate Pocket Alert, Discord, SMS, email, or any other vendor. Approved agent skills may implement transports while following the common provenance/authority contract.

See `a-rep/references/HUMAN_NOTIFICATIONS.md` and `a-rep/references/PROVENANCE.md`.

## Portability

The persistent agent is not the current model session. Codex and OpenCode are directly supported by the minimal PRIMARY launcher, and other capable execution surfaces can be added without changing durable identity.

Cold-start recovery is the correctness baseline. Provider-session resumption may later be explored as an optional optimization.

## Repository layout

The portable skill is under `a-rep/`.

- `a-rep/SKILL.md` — current operating rules.
- `a-rep/references/` — protocol, Issue, repository, runtime, event-wake, Guardian, provenance, human-notification, skill, and influence references.
- `a-rep/prompts/` — cold-start heartbeat, event, rejuvenation, and optional Guardian prompts.
- `a-rep/runtime/arep-run.sh` — PRIMARY launcher.
- `a-rep/runtime/arep-watch-github.sh` — cheap deterministic GitHub watcher.
- `a-rep/runtime/arep.conf.example` — runtime configuration example.
- `a-rep/runtime/cron.example` — watcher/heartbeat/rejuvenation schedule example.
- `a-rep/scripts/bootstrap-agent.sh` — bootstrap for a new private PRIMARY-agent repository.
- `a-rep/scaffold/agent-repo/` — canonical private-agent filesystem scaffold.
- `a-rep/tests/` — lightweight runtime/watcher regression tests.

A bootstrapped agent repository reserves Issues 1 through 20 for A Rep system use. Real work starts at Issue 21.

## Strategic context

Every agent has two standardized context layers.

`config/agent-context.md` is the short hot context read every PRIMARY and Guardian cycle.

`config/agent-context-deep.md` contains richer background loaded only when materially useful after current work/recovery needs are known.

Context helps interpretation; Issue 2, Issue 4, trusted current human instruction, approved procedures, runtime configuration, and direct evidence remain authoritative where applicable.

## Producer provenance

V1.3 introduced lightweight producer provenance for environments where multiple agent surfaces share the same GitHub account or bot identity.

Material agent-authored GitHub comments, reviews, and handoffs SHOULD begin with:

`[Agent | Platform | Role | Instance]`

Agent-authored Git commits SHOULD use an `Agent-Provenance:` trailer. Launcher-run PRIMARY cycles receive a UTC-stamped `Agent-Run` ID.

Provenance identifies the producer. It does **not** create authority, prove correctness, or make a Worker/Guardian into PRIMARY.

V1.4 uses provenance as a conservative routing hint to suppress clearly self-produced PRIMARY comments from causing event-wake feedback loops. Ambiguous origin is still treated as wake-worthy rather than silently discarded.

V1.4.1 applies the same header to human-facing notifications so transport identity does not erase producer/origin identity.

See `a-rep/references/PROVENANCE.md`.

## First-class skills

Experimental capabilities:

`scratch/skills/<skill-name>/SKILL.md`

Approved capabilities:

`procedures/skills/<skill-name>/SKILL.md`

PRIMARY may create, test, and evolve experimental skills autonomously within current work authority. Promotion into `procedures/skills/` requires review and explicit human approval.

A skill describes **capability/how**, not **permission**. No skill registry, database, package manager, marketplace, or dedicated skill API is required.

See `a-rep/references/SKILLS.md`.

## Guardian Angel

A Rep includes an optional provider-agnostic Guardian Angel review loop.

A Guardian can be scheduled independently through ChatGPT, Hermes, Claude, or another capable surface. It reads the same durable context/current work state, critically reviews PRIMARY direction, flags missing evidence/risk, suggests improvements, and may offer bounded help.

Guardian is advisory, not another PRIMARY. Its default write surface is GitHub Issue comments and it stays silent when there is nothing material to add.

With V1.4, a material Guardian Issue comment can wake PRIMARY through the GitHub watcher without giving Guardian any additional authority.

## Runtime and observability

Recommended active-agent schedule:

- GitHub watcher: every 1 minute;
- heartbeat scheduler poll: every 5 minutes;
- normal backup heartbeat: 30 minutes;
- fast/deadline heartbeat: 5 minutes.

The one-minute watcher is a cheap deterministic sensor. No relevant change means no model execution.

Heartbeat, event, and rejuvenation PRIMARY cycles share one local `flock`. Raw coding-agent output and local watcher/runtime state live under Git-ignored `.arep/`; concise sanitized operational logs may be tracked under `admin/logs/`.

Issue 16 is the canonical human-readable runtime record: body for current snapshot, comments for material transition history. Actual runtime config/direct host evidence remains authoritative if prose lags reality.

## Current status

**A Rep V1.4.1** is the current V1 release.

V1.4 adds the minimal GitHub event-wake path and moves the active-agent normal backup heartbeat baseline to 30 minutes, while retaining explicit fast/deadline controls for near-term scheduled work.

V1.4.1 adds the first-class human-notification provenance contract while deliberately leaving delivery adapters to approved agent skills rather than adding framework infrastructure.

See `CURRENT.md` and `CHANGELOG.md`.
