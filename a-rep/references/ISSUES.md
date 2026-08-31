# A Rep V1.3 reserved Issue topology

Each persistent PRIMARY agent repository reserves GitHub Issues 1 through 20 for framework and internal operating use.

Normal real work begins at Issue 21.

The reservation applies to agent repositories. It does not require the public A Rep framework repository itself to consume Issues 1 through 20.

## Durable-post provenance

Material agent-authored Issue comments, handoffs, reviews, and similar durable posts SHOULD begin with the producer header defined in `PROVENANCE.md`:

`[Agent | Platform | Role | Instance]`

For PRIMARY heartbeat records, reuse `Agent-Run` when available.

Do not prefix mutable shared current-state bodies such as Issue 1 Pulse or Issue 16 runtime snapshot with a producer header; these bodies represent current state rather than one producer's message. Use an accompanying material comment/log/commit for producer provenance when needed.

Provenance does not create authority, and old comments without headers remain valid.

## Reserved Issues

### Issue 1, Pulse

Current concise operational state.

Use it to answer what is happening now, what the agent is focused on, important waits or blockers, current heartbeat mode, and the next likely action.

Prefer editing the body or maintaining a concise current record rather than creating a noisy chronological log.

### Issue 2, Identity and Charter

Durable agent identity, role, purpose, high-level boundaries, standing authority, and relationship to the human or organization.

This remains authoritative over summaries in `config/agent-context.md`.

A provenance header saying `PRIMARY` does not supersede the authority recorded here.

### Issue 3, Execution Trail

Record material cross-cutting actions, results, meaningful failures, recoveries, incidents, and major state transitions.

This is the cross-cutting human-readable durable audit trail. Avoid logging every scheduler poll, routine heartbeat, or routine runtime/cadence transition merely because it happened. More granular sanitized executed-cycle history may live under tracked `admin/logs/`.

Runtime/cadence state has a dedicated home in Issue 16. Mirror a runtime event into Issue 3 only when it is also a material cross-cutting failure, recovery, incident, or major transition worth preserving outside the runtime record.

Execution-Trail comments produced by agents SHOULD carry producer provenance and `Agent-Run` when available.

### Issue 4, Human Decisions and Authority

Questions that genuinely require human intent or authority, standing approvals, consequential decisions, and their durable resolutions.

Do not use this Issue for routine implementation mechanics the agent can safely determine itself. Context files, skills, provenance headers, and Guardian comments cannot manufacture authority recorded here.

Human approval for a skill/procedure promotion may be recorded on the relevant proposal thread when clear and durable. Use Issue 4 when the approval also changes standing authority or is important enough to centralize as a consequential durable decision.

### Issue 5, Goal Stack and Priority Context

Current high-level goals, relative priorities, strategic emphasis, deadlines, and priority changes that span multiple work Issues.

This is not a duplicate task queue. Actual actionable work remains in Issues 21 and higher. The hot context file may summarize these priorities for efficient cold starts but does not replace this Issue.

### Issue 6, Evidence and Verification

Cross-cutting evidence standards, important verification results, and evidence that does not naturally belong to one work Issue.

Whenever evidence clearly belongs to one work Issue, prefer recording it there instead of duplicating it here.

### Issue 7, Recovery and Incidents

Material agent-runtime incidents, ambiguous recovery situations, corrupted or conflicting durable state, and the resolution needed for a fresh PRIMARY to resume safely.

Routine tool errors belong in the relevant work or execution trail unless they become a recovery problem.

### Issues 8 through 10, Reserved

Reserved for future V1.x internal needs. Do not create semantics merely to fill the numbers.

### Issue 11, Inbox

Targeted inbound communication intended for this PRIMARY.

This includes future persistent-agent coordination and Guardian Angel cross-cutting review, questions, warnings, or offers of bounded help.

PRIMARY should triage useful Inbox comments as advisory evidence. A Guardian comment does not itself change priorities, create authority, or prove that delegated work started.

Task-specific Guardian review should normally be posted directly on the relevant work Issue instead of duplicating it here.

Guardian comments SHOULD identify their Platform/Role/Instance provenance, especially when multiple Guardians share one GitHub account.

### Issue 12, Outbox

The agent's optional bulletin board.

Publish information that other agents may find useful without requiring them to consume or acknowledge it.

Another PRIMARY or Guardian may inspect this Issue when useful.

### Issue 13, Research

Backlog of worthwhile questions and investigations that do not necessarily justify immediate attention.

Open items may be revisited during free cycles or rejuvenation.

### Issue 14, Operational Improvements

Candidates for improving the agent's own nondeterministic methods, habits, decision process, recovery, organization, procedures, or reusable operating capabilities.

Guardian may post evidence-backed operational suggestions as comments here.

A skill promotion proposal may live here when the skill primarily packages an operational capability, but no special promotion Issue is required.

### Issue 15, Coding Improvements

Candidates for scripts, automation, tools, deterministic helpers, or other code that may replace repeated manual or nondeterministic work.

Guardian may post evidence-backed coding/automation suggestions as comments here.

A skill promotion proposal may live here when the skill is substantially a coding/tool capability.

### Issue 16, Runtime and Heartbeat Requests

Canonical human-readable runtime/heartbeat state and transition record.

Use the **Issue body** as a concise current snapshot of runtime state: current heartbeat mode, deadline state, important intervals, scheduler state, relevant host/runtime coordinates, and other facts worth seeing at a glance.

Use **comments** for material cadence/runtime requests, transitions, rationale, and verification history. Agent-authored material comments SHOULD carry producer provenance and the current `Agent-Run` when available.

The actual live/tracked runtime configuration and direct host evidence remain authoritative. If the Issue 16 body becomes stale or conflicts with the real configuration, PRIMARY should reconcile the body after verifying reality rather than treating stale prose as runtime truth.

Temporary workers and Guardian may request a change here but do not independently race to change active schedule state.

Machine-specific installation and recovery detail may also live under `admin/runtime/` in the private agent repository.

### Issue 17, Rejuvenation

Rejuvenation findings, current self-improvement focus, proposals, and material outcomes.

This may include evidence about experimental skills, repeated work that should become a skill, or promotion candidates that emerged during rejuvenation.

Do not activate rejuvenation merely because time has passed. Enable it when enough real execution history exists to expose recurring reasoning, recurring mistakes, reusable procedures/skills, research backlogs, or automation opportunities.

### Issues 18 through 20, Reserved

Leave unused until actual experience proves a stable framework-level need.

## Issues 21 and higher

Any one-time, recurring, limited-duration, monitoring, or ongoing responsibility that needs the PRIMARY's attention should normally be represented by an Issue while it remains on the agent's radar.

Recommended fields when useful:

- Outcome.
- Verification.
- Constraints.
- Boundaries.
- Stop when.
- Cadence or next check for recurring work.

These fields are guidance, not a mandatory schema.

When a productive cycle ends with incomplete work, leave a concise handoff if the next fresh cycle would otherwise have to reconstruct material state. Prefer current result/evidence, remaining work, blockers or waits, and the next useful step.

Material agent-authored handoffs SHOULD carry producer provenance and `Agent-Run` when available. A Worker handoff remains worker evidence until PRIMARY reconciles it.

If work reveals a genuinely reusable capability, the agent may create/evolve an experimental skill under `scratch/skills/` within current authority. That does not require creating another work Issue solely for the skill.

Close the Issue when the responsibility genuinely no longer requires attention.
