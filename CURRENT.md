# Current A Rep version

Current version, A Rep V1.1.

This repository uses a consolidated-current model. The current `a-rep/SKILL.md` and current supporting files define active behaviour. Historical changes belong in Git history or releases rather than additive patches that every agent must mentally compose.

## What V1.1 adds

V1.1 is a hardening and canonicalization release rather than a new architecture.

- Canonical private-agent scaffold under `a-rep/scaffold/agent-repo/`.
- Top-level `admin/`, `config/`, `scratch/`, `procedures/`, and `work/` zones with README guidance.
- `admin/logs/` for concise sanitized Git-visible operational logs.
- `.arep/raw-logs/` for raw coding-agent output, kept local and Git ignored.
- Recommended `.arep/primary.lock` and `.arep/heartbeat.last` runtime-state locations.
- Bootstrap now copies the canonical scaffold.
- Lightweight automated regression tests for the launcher.
- Clearer runtime/recovery documentation.

The runtime remains one tiny launcher plus cron wakeups. The coding agent remains the intelligence.

## Verification

The V1.1 launcher and automated runtime test suite pass shell syntax and isolated regression execution using a fake execution binary. The suite covers normal, fast, slow, paused, deadline acceleration, failed execution, success timestamp handling, due-skip, PRIMARY lock contention, rejuvenation disabled state, and deadline suppression.

Validation also caught and fixed two V1.1 implementation mistakes before handoff: test invocation counting across multiline prompts and unsafe unquoted Markdown backticks in the bootstrap-generated README.

Host-specific live-agent verification remains a deployment concern after pulling V1.1 onto that host.

## Deliberate exclusions

V1.1 still excludes persistent multi-PRIMARY coordination, a team repository, distributed locking, a custom database, queues, workflow engines, custom memory servers, dashboards, and other orchestration infrastructure.

Bounded execution timeout/stuck-cycle handling and versioned scaffold migrations are tracked as evidence-gated future improvements rather than implemented speculatively.

## First live agent

Fred's GitHub repository has been patched to the V1.1 scaffold/runtime conventions. Fred's runtime-host checkouts must be synchronized to current `main` and re-verified before receiving Issue 21.
