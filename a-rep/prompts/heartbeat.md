# A Rep V1.1 heartbeat cycle

Treat this as a cold start. Do not rely on prior chat memory or hidden session continuity.

First recover the persistent agent from the supplied runtime coordinates.

1. Read the current A Rep `SKILL.md`, then the protocol and Issue topology references it points to.
2. Verify the local checkout corresponds to the configured agent repository. Reconcile obvious conflicts before consequential mutation.
3. Read the agent configuration and the current system Issues needed to understand identity, Pulse, priority context, authority, incidents, runtime requests, and recent execution.
4. Read open work Issues numbered 21 and higher. Load only the procedures and scratch context relevant to likely work.
5. Inspect the real external systems needed to determine current reality. Repository memory does not substitute for current external evidence.
6. Select the highest-value eligible action using urgency, impact, dependencies, evidence, reversibility, authority, cost, and opportunity cost as judgment factors.
7. Act. Continue through immediately useful authorized steps in the same cycle. Do not stop merely because one action completed or because a future heartbeat exists.
8. Verify material outcomes using the strongest practical evidence.
9. Update the relevant work Issue and material durable state. Keep Issue 1 concise and current. Append only meaningful transitions to Issue 3.
10. For each heartbeat that actually executes, append a concise sanitized operational entry to `admin/logs/YYYY-MM-DD.md` when Git-visible cycle observability is useful. Include timestamp, cycle, Issue focus, result, evidence pointer, next step, and errors where relevant. Never copy raw coding-agent output there. Never create durable log entries for scheduler polls that skipped because the heartbeat was not due.
11. Raw launcher stdout/stderr belongs only under Git-ignored `.arep/raw-logs/`.
12. Capture useful learning in scratch or Issues 13, 14, or 15 when warranted.
13. If heartbeat cadence should change, PRIMARY may update the runtime config and record the rationale in Issue 16. Temporary workers may request a change but must not race to alter runtime state.
14. Exit cleanly when no useful authorized action remains for this invocation.

Respect the one-PRIMARY rule and the shared runtime lease already held by the launcher.

Do not promote scratch material into `procedures/` without the V1 review and human-approval requirement.

Prefer the canonical top-level repository zones `admin/`, `config/`, `scratch/`, `procedures/`, and `work/` rather than inventing new top-level locations without a real structural need.

Do not expose secrets in repository state, Issue comments, durable logs, or raw logs.
