#!/bin/sh
set -eu

# A Rep Event Bridge poller. Cheap, additive companion to arep-watch-github.sh:
# instead of polling GitHub's REST API every minute, this polls our own Cloudflare
# Worker every few seconds for a lightweight "something changed" flag set by a real
# GitHub webhook. On a hit, it writes the same .arep/github-event.pending file and
# calls the same arep-run.sh event launcher the 1-minute cron watcher already uses —
# no second execution path, per EVENT_WAKE.md's own webhook constraint. The 1-minute
# cron watcher keeps running unchanged as the redundant backup if this poller, the
# Worker, or GitHub's webhook delivery ever has an outage.

CONF="${1:-./config/arep.env}"

[ -f "$CONF" ] || { echo "Missing config: $CONF" >&2; exit 2; }
. "$CONF"

: "${AGENT_REPO_DIR:?AGENT_REPO_DIR is required}"
: "${EVENT_BRIDGE_AGENT_SLUG:?EVENT_BRIDGE_AGENT_SLUG is required (e.g. fred or sam)}"
: "${EVENT_BRIDGE_BASE_URL:?EVENT_BRIDGE_BASE_URL is required}"
: "${EVENT_BRIDGE_POLL_SECRET_FILE:?EVENT_BRIDGE_POLL_SECRET_FILE is required}"
: "${RUNTIME_DIR:=.arep}"
: "${EVENT_PENDING_FILE:=$RUNTIME_DIR/github-event.pending}"
: "${EVENT_BRIDGE_WATCH_LOCK_FILE:=$RUNTIME_DIR/event-bridge-watch.lock}"
: "${EVENT_BRIDGE_LAUNCH_ATTEMPT_FILE:=$RUNTIME_DIR/event-bridge-watch.last-attempt}"
: "${EVENT_BRIDGE_MIN_RETRY_SECONDS:=30}"

[ "${EVENT_BRIDGE_ENABLED:-true}" = "true" ] || exit 0
[ -f "$EVENT_BRIDGE_POLL_SECRET_FILE" ] || { echo "Missing Event Bridge poll secret file: $EVENT_BRIDGE_POLL_SECRET_FILE" >&2; exit 2; }

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LAUNCHER="$SCRIPT_DIR/arep-run.sh"
[ -f "$LAUNCHER" ] || { echo "Missing launcher: $LAUNCHER" >&2; exit 2; }

cd "$AGENT_REPO_DIR"
umask 077
mkdir -p "$RUNTIME_DIR"
mkdir -p "$(dirname "$EVENT_PENDING_FILE")"

exec 8>"$EVENT_BRIDGE_WATCH_LOCK_FILE"
flock -n 8 || exit 0

POLL_SECRET="$(cat "$EVENT_BRIDGE_POLL_SECRET_FILE")"
POLL_URL="$EVENT_BRIDGE_BASE_URL/webhooks/github/$EVENT_BRIDGE_AGENT_SLUG/pending"
ACK_URL="$EVENT_BRIDGE_BASE_URL/webhooks/github/$EVENT_BRIDGE_AGENT_SLUG/ack"

RESPONSE="$(curl -fsS --max-time 10 "$POLL_URL" -H "X-Poll-Secret: $POLL_SECRET")" || {
  echo "Event Bridge poll failed; leaving pending state as-is." >&2
  exit 0
}

case "$RESPONSE" in
  *'"pending":true'*) ;;
  *) exit 0 ;;
esac

HINT="$(printf '%s' "$RESPONSE" | python3 -c '
import json, sys
d = json.load(sys.stdin)
number = d.get("issueNumber")
title = d.get("issueTitle") or ""
url = d.get("url") or ""
sender = d.get("sender") or "unknown"
if number:
    print(f"- Webhook: Issue #{number} {title} updated by {sender} ({url})".rstrip())
else:
    print(f"- Webhook: repository change by {sender} ({url})".rstrip())
' 2>/dev/null)" || HINT="- Webhook: GitHub change detected (event-bridge)"

[ -n "$HINT" ] || HINT="- Webhook: GitHub change detected (event-bridge)"

TMP_PENDING="$(mktemp "$RUNTIME_DIR/event-bridge-pending.XXXXXX")"
trap 'rm -f "$TMP_PENDING"' EXIT HUP INT TERM
{
  [ -f "$EVENT_PENDING_FILE" ] && cat "$EVENT_PENDING_FILE"
  printf '%s\n' "$HINT"
} | tail -n 100 >"$TMP_PENDING"
mv "$TMP_PENDING" "$EVENT_PENDING_FILE"

# Local pending state now has the hint durably. Ack the Worker so it stops
# re-signaling the same already-captured event; the local pending file (and the
# launcher's own retry-until-consumed checksum logic) is now the source of truth.
curl -fsS --max-time 10 -X POST "$ACK_URL" -H "X-Poll-Secret: $POLL_SECRET" >/dev/null 2>&1 || true

if [ -s "$EVENT_PENDING_FILE" ]; then
  NOW_EPOCH="$(date -u +%s)"
  LAST_EPOCH="$(cat "$EVENT_BRIDGE_LAUNCH_ATTEMPT_FILE" 2>/dev/null || echo 0)"
  case "$LAST_EPOCH" in ''|*[!0-9]*) LAST_EPOCH=0 ;; esac
  ELAPSED=$((NOW_EPOCH - LAST_EPOCH))
  if [ "$ELAPSED" -ge "$EVENT_BRIDGE_MIN_RETRY_SECONDS" ]; then
    printf '%s\n' "$NOW_EPOCH" >"$EVENT_BRIDGE_LAUNCH_ATTEMPT_FILE"
    sh "$LAUNCHER" event "$CONF"
  fi
  # If under the cooldown, skip this attempt. This bounds worst-case launcher
  # invocation rate during an outage (e.g. Codex usage limit hit) instead of
  # hammering it every 5-20s; the existing 1-minute cron watcher's own retry
  # remains the natural floor either way.
fi
