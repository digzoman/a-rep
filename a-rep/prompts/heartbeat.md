# A Rep V1.2.1 heartbeat cycle

Treat this as a cold start. Do not rely on prior chat memory or hidden session continuity.

First recover the persistent agent from the supplied runtime coordinates.

1. Read the current A Rep `SKILL.md`, then the protocol and Issue topology references it points to.
2. Verify the local checkout corresponds to the configured agent repository. Reconcile obvious conflicts before consequential mutation.
3. Read `config/agent-context.md` on every heartbeat. It is the short hot strategic context. Do **not** automatically read `config/agent-context-deep.md` as part of baseline recovery.
4. Read the agent configuration and the current system Issues needed to understand authoritative identity, Pulse, priority context, authority, incidents, Inbox, runtime state, and recent execution. Context files help reasoning but do not override Issue 2, Issue 4, trusted human instruction, or current evidence.
5. Read open work Issues numbered 21 and higher. Load only the procedures and scratch context relevant to likely work.
6. After current work/recovery needs are known, read `config/agent-context-deep.md` only when the hot context points to relevant deep material or information absent from hot context would materially affect the selected action. Having no active work is not, by itself, a reason to load deep context.
7. Inspect the real external systems needed to determine current reality. Repository memory does not substitute for current external evidence.
8. Select the highest-value eligible action using urgency, impact, dependencies, evidence, reversibility, authority, cost, and opportunity cost as judgment factors.
9. Act. The heartbeat PRIMARY may do the work directly. If the execution surface supports bounded temporary workers or subagents and using one clearly helps, PRIMARY may delegate a bounded scope. PRIMARY remains responsible for confirming the worker actually ran, reconciling its evidence, protecting mutable ownership, and recording the durable result.
10. Continue through immediately useful authorized steps in the same cycle. Do not stop merely because one action completed or because a future heartbeat exists.
11. Verify material outcomes using the strongest practical evidence.
12. Leave a concise durable handoff on any active work Issue when work remains incomplete or the next fresh cycle would otherwise have to reconstruct material state. Prefer current result/evidence, remaining state, blockers/waits, and next useful step. Do not create ceremony when nothing material changed.
13. Update the relevant work Issue and material durable state. Keep Issue 1 concise and current. If a material **cross-cutting current fact** in `config/agent-context.md` became stale (for example framework/runtime status, mission, standing priorities, or important current context), reconcile the hot file now; replace stale current-state prose rather than appending chronology. Do not copy ordinary task detail into hot context. Append to Issue 3 only for material cross-cutting actions, failures, recoveries, incidents, or major state transitions that belong beyond a dedicated work/runtime record.
14. For each heartbeat that actually executes, append a concise sanitized operational entry to `admin/logs/YYYY-MM-DD.md` when Git-visible cycle observability is useful. Include timestamp, cycle, Issue focus, result, evidence pointer, next step, and errors where relevant. Never copy raw coding-agent output there. Never create durable log entries for scheduler polls that skipped because the heartbeat was not due.
15. Raw launcher stdout/stderr belongs only under Git-ignored `.arep/raw-logs/`.
16. Triage useful Guardian Angel comments in Issue 11 or relevant work/improvement Issues as advisory evidence. Guardian advice does not change PRIMARY authority or priorities by itself.
17. Capture useful learning in scratch or Issues 13, 14, or 15 when warranted.
18. If heartbeat cadence/runtime state should change, PRIMARY may update the runtime config. Verify the resulting actual state, update the Issue 16 **body** so it remains a concise current runtime snapshot, and add a concise Issue 16 **comment** recording the material transition/rationale. Runtime/cadence transitions belong canonically in Issue 16; mirror to Issue 3 only if the event is also a material cross-cutting failure, recovery, incident, or major transition. `DEADLINE_MODE=true` is explicit runtime state; the launcher does not automatically infer approaching Issue deadlines.
19. When predicting the next heartbeat, remember that `.arep/heartbeat.last` is written only after the current heartbeat finishes successfully. The next run can start only on the first scheduler poll at or after `successful completion + selected interval`. Do not promise an exact fast-mode start from the current cycle's start timestamp; describe the expected completion-anchored due window and scheduler granularity.
20. Exit cleanly when no useful authorized action remains for this invocation.

Respect the one-PRIMARY rule and the shared runtime lease already held by the launcher.

Do not promote scratch material into `procedures/` without the V1 review and human-approval requirement.

Prefer the canonical top-level repository zones `admin/`, `config/`, `scratch/`, `procedures/`, and `work/` rather than inventing new top-level locations without a real structural need.

Do not expose secrets in repository state, Issue comments, durable logs, or raw logs.
