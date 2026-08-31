# A Rep V1.3 skills

A Rep treats a skill as a reusable capability package that an agent can discover, create, test, evolve, and — after review — promote into trusted operating material.

Skills are first-class repository artifacts, but they do not require a skill registry, package manager, database, marketplace, or custom management service.

Ordinary filesystem operations, Git, Issues, and the agent's existing tools are enough.

## Skill versus procedure versus script

A **skill** is a reusable capability package. It may combine:

- instructions;
- judgment rules;
- prompts;
- checklists;
- scripts or code;
- templates;
- schemas;
- examples;
- tool-use patterns;
- evidence requirements;
- failure modes;
- learned heuristics.

A **procedure/SOP** is usually a trusted rule or process describing how the agent should perform a recurring operation.

A **script** implements mechanics deterministically.

These can overlap. A skill may reference an SOP, include a small script, call an approved shared script, or package templates/examples around a judgment-heavy capability.

## Canonical locations

Experimental skills:

`scratch/skills/<skill-name>/SKILL.md`

Approved durable skills:

`procedures/skills/<skill-name>/SKILL.md`

Skills SHOULD normally be directories even if they initially contain only `SKILL.md`. This leaves room for supporting material without later restructuring.

Example:

```text
scratch/skills/prospect-research/
  SKILL.md
  scripts/
  templates/
  examples/
```

Shared experimental scripts may remain under `scratch/scripts/`. Shared approved scripts may remain under `procedures/scripts/`.

Do not create an INDEX, database, or registry merely for discovery in V1.3. The filesystem is the authoritative catalogue: list `scratch/skills/*/SKILL.md` and `procedures/skills/*/SKILL.md`, then read concise front matter for candidates relevant to the current work.

If real skill volume later makes discovery expensive, add generated indexing only from evidence.

## Trust states

### Experimental

Material under `scratch/skills/` is experimental and untrusted.

Within the authority of current work, PRIMARY may autonomously:

- create an experimental skill;
- edit or refactor it;
- test it on real or synthetic work;
- add/remove supporting files;
- replace it;
- delete it when no longer useful.

Human approval is not required merely to create or evolve an experimental skill.

Experimental skill content remains lower trust than approved procedures and does not become authority merely because it is reusable.

### Approved

Material under `procedures/skills/` is trusted operating material.

Promotion from `scratch/skills/` into `procedures/skills/` requires review and explicit human approval under the existing V1 procedure-promotion rule.

Use a Git move or equivalent promotion when practical so normal Git history preserves provenance. Do not leave a redirect stub in `scratch/skills/` by default; duplicate discovery paths create ambiguity. Leave a redirect only when a concrete external reference requires one.

## Skill lifecycle

The normal lifecycle is:

`live work -> learning -> experimental skill -> real-use evidence -> promotion proposal -> review -> human approval -> approved skill`

More concretely:

1. Perform real work.
2. Notice repeated useful reasoning, tool use, a reusable capability, or a recurring failure pattern.
3. Check existing experimental and approved skills for substantial overlap.
4. Create `scratch/skills/<skill-name>/SKILL.md` when packaging the capability is likely to improve future work.
5. Use and refine it during authorized work.
6. Record concrete evidence and important evolution decisions.
7. Propose promotion when it is stable enough to become trusted behaviour.
8. Review the capability, evidence, dependencies, authority assumptions, failure modes, and near-duplicate skills.
9. Obtain explicit human approval.
10. Move/promote it into `procedures/skills/<skill-name>/`, add approved metadata, and update durable references that matter.

Do not manufacture a skill merely because the framework supports skills. Real work should create the pressure for reusable capability.

## Discovery

Before creating a new skill, inspect existing skill directories when relevant.

Prefer inexpensive discovery:

1. list candidate `SKILL.md` files;
2. inspect their concise `name`, `status`, and `trigger` metadata;
3. open full skill content only when the trigger suggests relevance.

This keeps skill discovery similar to hot/deep context: cheap routing first, full content only when useful.

## Minimal experimental SKILL.md

Recommended lightweight structure:

```markdown
---
name: competitor-research
status: experimental
trigger: Use when comparing current competitors for a market decision.
owner: Fred
created_from: Issue 23
related_skills: []
---

# Competitor Research

## Purpose

## When to use

## Inputs

## Outputs

## Method

## Evidence requirements

## Tools and scripts

## Failure modes

## Learnings / evolution
```

### Trigger

`trigger` SHOULD be one concise, condition-oriented sentence that lets an agent decide relevance without loading the full skill.

Keep it short; around 70 characters is a portability target when practical, not a hard universal parser limit. Do not turn the trigger into a paragraph.

### Related skills

`related_skills` is optional in substance even if represented as an empty list in a template. Use it when it helps distinguish adjacent capabilities or avoid near-duplicates.

Do not manufacture relationships for every skill.

### Version

Git history is the authoritative version history of experimental skills. Explicit semantic versioning is optional while a skill remains in scratch.

An approved skill SHOULD carry an explicit version so durable trusted capability can be referenced precisely, for example:

```yaml
status: approved
version: 1.0.0
approved_by: human
approved_from: Issue 14
```

Do not create meaningless patch-version churn for every experimental edit.

## Learnings / evolution

Experimental skills SHOULD maintain a concise `Learnings / evolution` section when the capability changes for an evidence-backed reason.

Prefer concrete statements such as:

- what failed or repeated;
- what changed;
- why it changed;
- evidence or work reference supporting the change.

Git diffs remain the detailed history. Prefer focused edits that make the change inspectable rather than rewriting unrelated skill content without reason.

## Skill creation breadcrumb

When an experimental skill is first created during a productive cycle, leave a lightweight durable breadcrumb when normal cycle logging is already appropriate — for example in the relevant work Issue handoff or the cycle's sanitized `admin/logs/` entry.

The breadcrumb should identify the skill path and why it was created. Do not create a special registry or dedicated log solely for skill creation.

## Dependencies

Experimental skills may depend on experimental or approved resources when the dependency is clear and useful.

Approved skills SHOULD normally depend only on approved/stable resources.

An approved skill must not silently depend on a mutable experimental script or scratch skill, because that would allow trusted behaviour to change underneath the approval boundary.

If an approved skill intentionally calls an experimental dependency, the exception requires explicit human authorization and should be clearly marked as experimental at the dependency point.

## Tools and scripts

A skill may:

- contain tiny code snippets directly in `SKILL.md`;
- contain skill-specific `scripts/`, `templates/`, `examples/`, or schemas within its directory;
- reference shared scripts in `scratch/scripts/` or `procedures/scripts/` according to trust level;
- reference approved procedures or existing external tools.

Do not build a dedicated skill-management API merely to create/list/promote skills. A Rep agents already have normal file operations, shell, Git, and Issues.

## Promotion review

Before recommending or approving promotion, review at least:

- Is the capability genuinely reusable rather than one-off trivia?
- What real evidence shows it improves work, consistency, recovery, or efficiency?
- Does an existing experimental or approved skill substantially duplicate it?
- Are its inputs, outputs, evidence requirements, and failure modes clear enough?
- Does it depend only on resources appropriate to its trust level?
- Does it accidentally encode permissions the agent does not possess?
- Is any consequential action still protected by normal authority rules?
- Is the capability stable enough to become trusted operating material?

Guardian may point out duplicate skills, weak evidence, unstable dependencies, or missing failure modes, but Guardian cannot promote a skill without explicit human approval.

## Skills do not create authority

A skill describes capability: *how to perform something*.

It does not grant permission: *whether this agent is allowed to do it now*.

A skill may explain how to send outreach, deploy software, modify a CRM, spend from an ad account, or perform another consequential operation. The underlying action still requires authority from trusted human instruction, Issue 2/4 standing authority, current authorized work, approved configuration/procedures, and applicable A Rep rules.

An approved skill is trusted **how**, not self-created **permission**.

## Workers and skills

PRIMARY may give a bounded Worker a relevant approved skill or an experimental skill being tested.

The worker should receive only the capability/context needed for its bounded scope. Worker use of a skill does not make worker output authoritative; PRIMARY remains responsible for reconciliation and verification.

A worker may improve an experimental skill within delegated scope, but it may not promote that skill into `procedures/skills/` unless the required human approval already exists and PRIMARY reconciles the promotion.

## Guardian and skills

Guardian should inspect skills when relevant to the work or when reviewing self-improvement.

Useful Guardian checks include:

- repeated work that may deserve an experimental skill;
- near-duplicate or conflicting skills;
- experimental skills that have accumulated enough evidence to propose promotion;
- approved skills that have stale assumptions or unstable dependencies;
- proposed promotion without adequate evidence or human approval.

Guardian advice remains advisory evidence, not promotion authority.

## Backward compatibility

V1.3 skill support is additive.

Existing A Rep repositories that already have `procedures/skills/` remain valid. Existing repos may simply add `scratch/skills/` and update the procedures/skills guidance during migration.

No existing scratch document, SOP, script, or skill needs to be moved merely because V1.3 exists. Promote/reorganize only when doing so improves real use.
