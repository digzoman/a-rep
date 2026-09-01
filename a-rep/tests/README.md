# A Rep tests

Run from the repository checkout with:

```sh
sh a-rep/tests/runtime-test.sh
sh a-rep/tests/github-watch-test.sh
sh a-rep/tests/optional-skills-test.sh
```

The runtime/watcher suites use temporary repositories and fake execution/GitHub binaries. They do not require a live paid coding-agent call and do not modify real agent repositories or cron.

`optional-skills-test.sh` exercises the V1.5 `plan-work` and `data-ledger` helpers with temporary Markdown/CSV fixtures. It verifies rebuildable indexes, due/overdue plan reporting, durable fresh-process recovery, replanning history, CSV snapshots, stable-identity lookup, idempotent event append, external business authority labelling, and the absence of generated JSON/hidden state.
