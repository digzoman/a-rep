# scratch/skills

Experimental reusable capability packages.

Use one directory per skill:

`scratch/skills/<skill-name>/SKILL.md`

PRIMARY may create, test, edit, evolve, replace, or remove experimental skills autonomously when doing so is within current work authority.

Before creating a new skill, inspect relevant existing experimental and approved skills for substantial overlap.

A lightweight experimental `SKILL.md` should normally include concise front matter such as:

```yaml
---
name: competitor-research
status: experimental
trigger: Use when comparing current competitors for a market decision.
owner: Fred
created_from: Issue 23
related_skills: []
---
```

Then document Purpose, When to use, Inputs, Outputs, Method, Evidence requirements, Tools and scripts, Failure modes, and Learnings/evolution as useful.

Keep `trigger` to one concise condition-oriented sentence so agents can decide relevance without loading every full skill. Around 70 characters is a portability target when practical, not a hard universal limit.

Git history is sufficient version history while a skill is experimental; semantic versioning is optional in scratch.

Promotion into `procedures/skills/` requires review and explicit human approval. Do not move material there merely because an agent created or repeatedly used it.

Skills describe capability, not authority. A skill never grants permission for consequential actions.

See the public A Rep `references/SKILLS.md` for the full lifecycle and dependency rules.
