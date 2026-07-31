#!/usr/bin/env bash
# run-hooks-offline.sh - Chapter 6. Feeds the fixtures to each handler and
# prints what it emits, so you can read the five hooks without starting a
# Claude Code session.
#
# Usage:  ./run-hooks-offline.sh [vault-path]
#
# With no argument it works on a throwaway copy of ../../sample-vault. Pass
# your own vault and it copies that instead. It never writes to the vault you
# name - PostToolUse genuinely creates a daily note, so it gets a copy.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC_VAULT="${1:-$HERE/../../sample-vault}"

command -v jq >/dev/null 2>&1 || {
  echo "jq is required. brew install jq / apt install jq / winget install jqlang.jq" >&2
  exit 1
}
[[ -d "$SRC_VAULT" ]] || { echo "not a directory: $SRC_VAULT" >&2; exit 1; }

VAULT="$(mktemp -d)"
trap 'rm -rf "$VAULT"' EXIT
cp -R "$SRC_VAULT/." "$VAULT/"
export CLAUDE_PROJECT_DIR="$VAULT"

TODAY="$(date +%Y-%m-%d)"
BOOK="$HERE/hooks"
FIXED="$HERE/hooks-fixed"

feed() { sed "s|SAMPLE_VAULT|$VAULT|g" "$HERE/fixtures/$1"; }
rule() { printf '\n%s\n%s\n' "$1" "$(printf '=%.0s' $(seq 1 ${#1}))"; }
ctx()  { jq -r '.hookSpecificOutput.additionalContext // "(no additionalContext)"'; }

echo "vault copy: $VAULT"
echo "source:     $SRC_VAULT"

rule "1. SessionStart -> reads CLAUDE.md, injects it"
feed session-start.json | bash "$BOOK/session-start.sh" | ctx | head -8
echo "  ... (truncated; the handler injects all of CLAUDE.md)"

rule "2. UserPromptSubmit -> re-injects the schema slice"
echo "--- book version (hooks/) ---"
bash "$BOOK/user-prompt-submit.sh" | ctx | grep 'Active project'
echo "--- repaired version (hooks-fixed/) ---"
bash "$FIXED/user-prompt-submit.sh" | ctx | grep 'Active project'
echo "The book's awk looks for '## Active Projects' and backticked paths."
echo "The book's own CLAUDE.md writes '# Active Projects' and bare paths."

rule "3. PostToolUse -> appends a line to daily/$TODAY.md"
for f in post-tool-use-file-path post-tool-use-path post-tool-use-no-path; do
  feed "$f.json" | python3 "$BOOK/post-tool-use.py"
  printf '  fed %-28s -> %s\n' "$f.json" "$(tail -1 "$VAULT/daily/$TODAY.md")"
done
echo "Third fixture carries neither file_path nor path. The handler logs '?'"
echo "rather than crashing, which is the behaviour you want in a hook."

rule "4. PreCompact -> asks Claude to write decisions down first"
bash "$BOOK/pre-compact.sh" | ctx | head -3
echo "  ... (fixed directive, no reader input by design - ch06:288)"

rule "5. Stop -> only fires when PostToolUse actually logged something"

# stdout and stderr are kept apart on purpose: the book's handler writes a
# shell error to stderr AND the closer to stdout on the same run, and piping
# the two together just feeds the error text to jq.
verdict() {
  local script="$1" out err
  err="$(mktemp)"
  out="$(bash "$script" 2>"$err" || true)"
  if [[ -n "$out" ]]; then printf 'injected the closer'; else printf 'silent'; fi
  # the error text itself spans two lines, because the value that broke the
  # test is literally "0\n0" - squash it onto one line to read it
  [[ -s "$err" ]] && printf '   <- %s' "$(tr '\n' ' ' <"$err" | sed 's#^.*/##' | cut -c1-72)"
  rm -f "$err"
}

for state in daily-no-heading daily-no-activity daily-with-activity; do
  cp "$HERE/fixtures/$state.md" "$VAULT/daily/$TODAY.md"
  case "$state" in
    daily-with-activity) want="inject" ;;
    *)                   want="stay silent" ;;
  esac
  printf '\n  daily note state: %-20s (correct behaviour: %s)\n' "$state" "$want"
  printf '    book version:     %s\n'  "$(verdict "$BOOK/stop.sh")"
  printf '    repaired version: %s\n'  "$(verdict "$FIXED/stop.sh")"
done
echo
echo "On the two states with no logged activity the book's guard is supposed to"
echo "exit silently. It injects the closer anyway. That is the bug the repaired"
echo "copy fixes; tests/run.sh asserts both halves."
