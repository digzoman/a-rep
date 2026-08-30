# A Rep runtime tests

Run from the repository checkout with:

```sh
sh a-rep/tests/runtime-test.sh
```

The suite uses a temporary agent repository and a fake execution binary. It does not require a live Codex/OpenCode call and does not modify real agent repositories or cron.

It covers cadence modes, deadline behaviour, missing configuration, failed execution, heartbeat success state, due-skip, PRIMARY lock contention, and rejuvenation suppression.
