# A Rep V1.2 heartbeat cycle

Treat this as a cold start. Do not rely on prior chat memory or hidden session continuity.

First recover the persistent agent from the supplied runtime coordinates.

1. Read the current A Rep `SKILL.md`, then the protocol and Issue topology references it points to.
2. Verify the local checkout corresponds to the configured agent repository. Reconcile obvious conflicts before consequential mutation.
3. Read `config/agent-context.md` on every heartbeat. It is the short hot strategic context. Read `config/agent-context-deep.md` only when the hot context points to it, the active work is unclear, or deeper organizational/strategic background materially improves the selected work.
4. Read the agent configuration and the current system Issues needed to understand authoritative identity, Pulse, priority context, authority, incidents, Inbox, runtime requests, and recent execution. Context files help reasoning but do not override Issue 2, Issue 4, trusted human instruction, or current evidence.
5. Read open work Issues numbered 21 and higher. Load only the procedures and scratch context relevant to likely work.
6. Inspect the real external systems needed to determine current reality. Repository memory does not substitute for current external evidence.
7. Select the highest-value eligible action using urgency, impact, dependencies, evidence, reversibility, authority, cost, and opportunity cost as judgment factors.
8. Act. The heartbeat PRIMARY may do the work directly. If the execution surface supports bounded temporary workers or subagents and using one clearly helps, PRIMARY may delegate a bounded scope. PRIMARY remains responsible for confirming the worker actually ran, reconciling its evidence, protecting mutable ownership, and recording the durable result.
9. Continue through immediately useful authorized steps in the same cycle. Do not stop merely because one action completed or because a future heartbeat exists.
10. Verify material outcomes using the strongest practical evidence.
11. Leave a concise durable handoff on any active work Issue when work remains incomplete or the next fresh cycle would otherwise have to reconstruct material state. Prefer current result/evidence, remaining state, blockers/waits, and next useful step. Do not create ceremony when nothing material changed.
12. Update the relevant work Issue and material durable state. Keep Issue 1 concise and current. Append only meaningful transitions to Issue 3.
13. For each heartbeat that actually executes, append a concise sanitized operational entry to `admin/logs/YYYY-MM-DD.md` when Git-visible cycle observability is useful. Include timestamp, cycle, Issue focus, result, evidence pointer, next step, and errors where relevant. Never copy raw coding-agent output there. Never create durable log entries for scheduler polls that skipped because the heartbeat was not due.
14. Raw launcher stdout/stderr belongs only under Git-ignored `.arep/raw-logs/`.
15. Triage useful Guardian Angel comments in Issue 11 or relevant work/improvement Issues as advisory evidence. Guardian advice does not change PRIMARY authority or priorities by itself.
16. Capture useful learning in scratch or Issues 13, 14, or 15 when warranted.
17. If heartbeat cadence should change, PRIMARY may update the runtime config and record the rationale in Issue 16. `DEADLINE_MODE=true` is an explicit runtime setting; the V1.2 launcher does not automatically infer approaching Issue deadlines. Temporary workers may request a change but must not race to alter runtime state.
18. Exit cleanly when no useful authorized action remains for this invocation.

Respect the one-PRIMARY rule and the shared runtime lease already held by the launcher.

Do not promote scratch material into `procedures/` without the V1 review and human-approval requirement.

Prefer the canonical top-level repository zones `admin/`, `config/`, `scratch/`, `procedures/`, and `work/` rather than inventing new top-level locations without a real structural need.

Do not expose secrets in repository state, Issue comments, durable logs, or raw logs.
