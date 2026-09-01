# A Rep

A Rep is a lightweight, nondeterministic-first Repeating Agent Framework.

Its purpose is to let a capable coding agent operate as a persistent, goal-seeking, self-improving agent by following one portable skill and using a private Git repository plus current external evidence as durable operating state.

A Rep does not require a dedicated orchestration platform. In V1, the coding agent is the execution engine, the skill is the operating protocol, the agent repository is durable control/context/memory state, and tiny deterministic schedulers provide wakeups.

## V1 thesis

A PRIMARY repeatedly reconstructs reality, reads concise strategic context, selects the highest-value eligible action, acts, verifies the result, records durable state, leaves a fresh-session handoff when needed, learns, and repeats.

A Rep begins with judgment rather than a predetermined workflow. Stable recurring behaviour may later be formalized into reviewed procedures, scripts, skills, or graph-based workflows.

## V1.5: optional durable work skills

V1.5 adds two approved generic skills to the canonical private-agent scaffold without changing the runtime architecture:

- `plan-work` — optional Markdown planning/recovery for already-authorized work spanning multiple meaningful chunks or PRIMARY runs;
- `data-ledger` — optional Markdown + CSV working/audit state for evolving structured records.

They are deliberately boring. They do not add a workflow engine, CRM, database, scheduler, queue, second PRIMARY, or new authority model.

When used, live artifacts stay inside the existing `work/` zone:

```text
work/plans/<plan-id>/PLAN.md
work/plans/<plan-id>/EVENTS.md
work/data/<ledger-id>/README.md
work/data/<ledger-id>/snapshot.csv
work/data/<ledger-id>/events.csv
```

Optional `INDEX.md` files are generated convenience views and are never authoritative.

The tiny helpers are shipped with the approved skills:

```text
procedures/skills/plan-work/planctl.py
procedures/skills/data-ledger/ledgerctl.py
```

`planctl.py` only reindexes, reports status, and identifies due/overdue plans. `ledgerctl.py` only reindexes, finds by stable identity, and appends idempotent events. PRIMARY still provides the judgment.

See the skill packages in `a-rep/scaffold/agent-repo/procedures/skills/`.

## V1.4: event wake + backup heartbeat

V1.4 separates responsiveness from recovery without adding an orchestration service.

A tiny GitHub watcher may poll the private agent repository every minute. If nothing meaningful changed, it exits without launching the model. If it sees a new Issue, reopened Issue, or non-self Issue comment, it requests an immediate `event` PRIMARY wake through the same local PRIMARY lease used by heartbeat/rejuvenation.

Separately, the normal heartbeat remains a recovery/liveness fallback. The recommended/default normal backup interval for an active agent is 30 minutes; the heartbeat cron may still poll every five minutes so explicit fast/deadline mode can take effect quickly.

If PRIMARY knows authorized scheduled work needs another wake sooner than the normal backup, it should explicitly use existing fast/deadline behavior or an already-authorized external scheduler when exact timing genuinely requires it. A Rep does not infer business deadlines from prose.

## V1.4.1: provenance-preserving human notifications

Material phone pushes, Discord messages, emails, or similar alerts SHOULD reuse the same provenance header already used in GitHub:

`[Agent | Platform | Role | Instance]`

For transports with a title/subject, that visible title SHOULD be an exact provenance header. If one A Rep surface originates the message and another surface relays/delivers it, preserve the origin header as the title and add `Relayed-By: [Agent | Platform | Role | Instance]` for the delivering surface.

A notification gets human attention; it does not itself create approval or authority.

A Rep does not mandate a notification vendor. Approved agent skills may implement transports while following the common provenance/authority contract.

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
- `a-rep/scaffold/agent-repo/` — canonical private-agent filesystem scaffold, including framework-shipped approved optional skills.
- `a-rep/tests/` — lightweight runtime/watcher/optional-skill regression tests.

A bootstrapped agent repository reserves Issues 1 through 20 for A Rep system use. Real work starts at Issue 21.

## Strategic context

Every agent has two standardized context layers.

`config/agent-context.md` is the short hot context read every PRIMARY and Guardian cycle.

`config/agent-context-deep.md` contains richer background loaded only when materially useful after current work/recovery needs are known.

Context helps interpretation; Issue 2, Issue 4, trusted current human instruction, approved procedures, runtime configuration, and direct evidence remain authoritative where applicable.

## Producer provenance

Material agent-authored GitHub comments, reviews, and handoffs SHOULD begin with:

`[Agent | Platform | Role | Instance]`

Agent-authored Git commits SHOULD use an `Agent-Provenance:` trailer. Launcher-run PRIMARY cycles receive a UTC-stamped `Agent-Run` ID.

Provenance identifies the producer. It does not create authority, prove correctness, or make a Worker/Guardian into PRIMARY.

## First-class skills

Experimental capabilities:

`scratch/skills/<skill-name>/SKILL.md`

Approved capabilities:

`procedures/skills/<skill-name>/SKILL.md`

PRIMARY may create, test, and evolve experimental skills autonomously within current work authority. Promotion into `procedures/skills/` requires review and explicit human approval. Accepted framework releases may also ship approved generic skills in the canonical scaffold.

A skill describes capability/how, not permission. No skill registry, database, package manager, marketplace, or dedicated skill API is required.

See `a-rep/references/SKILLS.md`.

## Guardian Angel

A Rep includes an optional provider-agnostic Guardian Angel review loop.

A Guardian can be scheduled independently through ChatGPT, Hermes, Claude, or another capable surface. It reads the same durable context/current work state, critically reviews PRIMARY direction, flags missing evidence/risk, suggests improvements, and may offer bounded help.

Guardian is advisory, not another PRIMARY. Its default write surface is GitHub Issue comments and it stays silent when there is nothing material to add.

A material Guardian Issue comment can wake PRIMARY through the GitHub watcher without giving Guardian any additional authority.

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

**A Rep V1.5.0** is the current V1 release.

V1.5 adds optional `plan-work` and `data-ledger` approved framework skills using Markdown/CSV and tiny standard-library helpers. Runtime behavior remains V1.4.x.

See `CURRENT.md` and `CHANGELOG.md`.
