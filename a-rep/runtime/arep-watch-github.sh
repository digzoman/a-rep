#!/bin/sh
set -eu

CONF="${1:-./config/arep.env}"

[ -f "$CONF" ] || { echo "Missing config: $CONF" >&2; exit 2; }
. "$CONF"

: "${AGENT_REPO:?AGENT_REPO is required}"
: "${AGENT_REPO_DIR:?AGENT_REPO_DIR is required}"
: "${EXECUTION_DRIVER:=codex}"
: "${RUNTIME_DIR:=.arep}"
: "${GITHUB_WATCH_CURSOR_FILE:=$RUNTIME_DIR/github-watch.cursor}"
: "${GITHUB_WATCH_LOCK_FILE:=$RUNTIME_DIR/github-watch.lock}"
: "${EVENT_PENDING_FILE:=$RUNTIME_DIR/github-event.pending}"
: "${GITHUB_WATCH_BIN:=gh}"

[ "${GITHUB_WATCH_ENABLED:-true}" = "true" ] || exit 0

command -v "$GITHUB_WATCH_BIN" >/dev/null 2>&1 || { echo "GitHub watcher requires: $GITHUB_WATCH_BIN" >&2; exit 2; }

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LAUNCHER="$SCRIPT_DIR/arep-run.sh"
[ -f "$LAUNCHER" ] || { echo "Missing launcher: $LAUNCHER" >&2; exit 2; }

cd "$AGENT_REPO_DIR"
umask 077
mkdir -p "$RUNTIME_DIR"
mkdir -p "$(dirname "$GITHUB_WATCH_CURSOR_FILE")" "$(dirname "$GITHUB_WATCH_LOCK_FILE")" "$(dirname "$EVENT_PENDING_FILE")"

exec 8>"$GITHUB_WATCH_LOCK_FILE"
flock -n 8 || exit 0

poll_started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if [ ! -f "$GITHUB_WATCH_CURSOR_FILE" ]; then
  printf '%s\n' "$poll_started_at" >"$GITHUB_WATCH_CURSOR_FILE"
  if [ -s "$EVENT_PENDING_FILE" ]; then
    sh "$LAUNCHER" event "$CONF"
  fi
  exit 0
fi

cursor="$(cat "$GITHUB_WATCH_CURSOR_FILE" 2>/dev/null || true)"
case "$cursor" in
  ????-??-??T??:??:??Z) ;;
  *)
    echo "Invalid GitHub watcher cursor; reinitializing without replay." >&2
    printf '%s\n' "$poll_started_at" >"$GITHUB_WATCH_CURSOR_FILE"
    exit 0
    ;;
esac

TMP="$(mktemp -d "$RUNTIME_DIR/github-watch.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
COMMENTS="$TMP/comments"
ISSUES="$TMP/issues"
REOPENED="$TMP/reopened"
NEW_EVENTS="$TMP/new-events"
: >"$NEW_EVENTS"

if ! "$GITHUB_WATCH_BIN" api "repos/$AGENT_REPO/issues/comments?since=$cursor&per_page=100" \
  --jq '.[] | [.html_url, ((.body // "") | split("\n")[0])] | @tsv' >"$COMMENTS"; then
  echo "GitHub watcher comment poll failed; cursor not advanced." >&2
  exit 1
fi

if ! "$GITHUB_WATCH_BIN" api "repos/$AGENT_REPO/issues?state=all&since=$cursor&per_page=100" \
  --jq ".[] | select(.pull_request == null) | select(.created_at >= \"$cursor\") | [.number, .html_url, .title] | @tsv" >"$ISSUES"; then
  echo "GitHub watcher issue poll failed; cursor not advanced." >&2
  exit 1
fi

if ! "$GITHUB_WATCH_BIN" api "repos/$AGENT_REPO/issues/events?per_page=100" \
  --jq ".[] | select(.event == \"reopened\") | select(.created_at >= \"$cursor\") | [.issue.number, .issue.html_url] | @tsv" >"$REOPENED"; then
  echo "GitHub watcher reopened-event poll failed; cursor not advanced." >&2
  exit 1
fi

platform="${PROVENANCE_PLATFORM:-$EXECUTION_DRIVER}"
self_primary_marker=" | $platform | PRIMARY | "

tab="$(printf '\t')"
while IFS="$tab" read -r url first_line; do
  [ -n "$url" ] || continue
  case "$first_line" in
    *"$self_primary_marker"*) ;;
    *) printf '%s\n' "- New or updated Issue comment: $url" >>"$NEW_EVENTS" ;;
  esac
done <"$COMMENTS"

while IFS="$tab" read -r number url title; do
  [ -n "$number" ] || continue
  printf '%s\n' "- New Issue #$number: $title ($url)" >>"$NEW_EVENTS"
done <"$ISSUES"

while IFS="$tab" read -r number url; do
  [ -n "$number" ] || continue
  printf '%s\n' "- Issue #$number reopened: $url" >>"$NEW_EVENTS"
done <"$REOPENED"

# Advance only after every GitHub read succeeded. Using poll start time avoids
# losing events created while these API calls were in flight.
printf '%s\n' "$poll_started_at" >"$GITHUB_WATCH_CURSOR_FILE"

if [ -s "$NEW_EVENTS" ]; then
  PENDING_TMP="$TMP/pending"
  {
    [ -f "$EVENT_PENDING_FILE" ] && cat "$EVENT_PENDING_FILE"
    cat "$NEW_EVENTS"
  } | tail -n 100 >"$PENDING_TMP"
  mv "$PENDING_TMP" "$EVENT_PENDING_FILE"
fi

if [ -s "$EVENT_PENDING_FILE" ]; then
  sh "$LAUNCHER" event "$CONF"
fi
