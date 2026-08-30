# A Rep V1 reserved Issue topology

Each persistent PRIMARY agent repository reserves GitHub Issues 1 through 20 for framework and internal operating use.

Normal real work begins at Issue 21.

The reservation applies to agent repositories. It does not require the public A Rep framework repository itself to consume Issues 1 through 20.

## Reserved Issues

### Issue 1, Pulse

Current concise operational state.

Use it to answer what is happening now, what the agent is focused on, important waits or blockers, current heartbeat mode, and the next likely action.

Prefer editing the body or maintaining a concise current record rather than creating a noisy chronological log.

### Issue 2, Identity and Charter

Durable agent identity, role, purpose, high-level boundaries, standing authority, and relationship to the human or organization.

This is not conversational persona decoration. It is the durable answer to who this PRIMARY is and what it exists to accomplish.

### Issue 3, Execution Trail

Append material actions, results, meaningful failures, recoveries, and major state transitions.

This is the human-readable durable audit trail. Avoid logging every trivial thought or tool call.

### Issue 4, Human Decisions and Authority

Questions that genuinely require human intent or authority, standing approvals, consequential decisions, and their durable resolutions.

Do not use this Issue for routine implementation mechanics the agent can safely determine itself.

### Issue 5, Goal Stack and Priority Context

Current high-level goals, relative priorities, strategic emphasis, deadlines, and priority changes that span multiple work Issues.

This is not a duplicate task queue. Actual actionable work remains in Issues 21 and higher.

### Issue 6, Evidence and Verification

Cross-cutting evidence standards, important verification results, and evidence that does not naturally belong to one work Issue.

Whenever evidence clearly belongs to one work Issue, prefer recording it there instead of duplicating it here.

### Issue 7, Recovery and Incidents

Material agent-runtime incidents, ambiguous recovery situations, corrupted or conflicting durable state, and the resolution needed for a fresh PRIMARY to resume safely.

Routine tool errors belong in the relevant work or execution trail unless they become a recovery problem.

### Issues 8 through 10, Reserved

Reserved for future V1.x internal needs. Do not create semantics merely to fill the numbers.

### Issue 11, Inbox

Targeted inbound communication from another PRIMARY agent or future coordination surface.

Inbox communication is intended for this agent and should eventually be triaged.

V1 may leave this mostly unused until multiple persistent agents exist.

### Issue 12, Outbox

The agent's optional bulletin board.

Publish information that other agents may find useful without requiring them to consume or acknowledge it.

Another PRIMARY may inspect this Issue when it wants to know what this agent is announcing or making visible to peers.

### Issue 13, Research

Backlog of worthwhile questions and investigations that do not necessarily justify immediate attention.

Open items may be revisited during free cycles or rejuvenation.

### Issue 14, Operational Improvements

Candidates for improving the agent's own nondeterministic methods, habits, decision process, recovery, organization, or procedures.

### Issue 15, Coding Improvements

Candidates for scripts, automation, tools, deterministic helpers, or other code that may replace repeated manual or nondeterministic work.

### Issue 16, Runtime and Heartbeat Requests

Requests and rationale for heartbeat or runtime changes.

The actual runtime configuration remains authoritative. Temporary workers may request a change here but do not independently race to change the active schedule.

### Issue 17, Rejuvenation

Rejuvenation findings, current self-improvement focus, proposals, and material outcomes.

### Issues 18 through 20, Reserved

Leave unused until actual experience proves a stable framework-level need.

## Issues 21 and higher

Any one-time, recurring, limited-duration, monitoring, or ongoing responsibility that needs the PRIMARY's attention should normally be represented by an Issue while it remains on the agent's radar.

Recommended fields when useful.

- Outcome.
- Verification.
- Constraints.
- Boundaries.
- Stop when.
- Cadence or next check for recurring work.

These fields are guidance, not a mandatory schema.

Close the Issue when the responsibility genuinely no longer requires attention.
