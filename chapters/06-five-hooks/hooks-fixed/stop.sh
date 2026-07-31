#!/usr/bin/env bash
# stop.sh - Chapter 6. Injects the session-closer directive, but only if the
# session actually touched the vault.
#
# REPAIRED. The book's version is next door in hooks/ and is byte-identical to
# the page. Its activity count is:
#
#   ACTIVITY=$(awk ... | grep -c '^- ' || echo 0)
#
# On a daily note with no activity lines, `grep -c` prints 0 AND exits 1. So
# the `|| echo 0` fires too and ACTIVITY becomes the two-line string "0\n0",
# which the numeric test below cannot parse. Under bash that is
# `[[: 0\n0: syntax error`, the guard reads false, and the closer directive is
# injected on a session that did nothing - the exact opposite of what ch06:343
# says the guard is for. Under zsh it is worse: `bad math expression`, exit 1,
# hook dead. Fix: let grep fail quietly, keep only the leading digits.
set -euo pipefail

VAULT="${CLAUDE_PROJECT_DIR:-.}"
TODAY=$(date +%Y-%m-%d)
DAILY="$VAULT/daily/${TODAY}.md"

[[ -f "$DAILY" ]] || exit 0

ACTIVITY=$(awk '/^## Vault Activity/{f=1;next} /^## /{f=0} f' "$DAILY" \
  | grep -c '^- ' || true)
ACTIVITY="${ACTIVITY%%[!0-9]*}"

if [[ "${ACTIVITY:-0}" -eq 0 ]]; then
  exit 0
fi

DIRECTIVE="Session ending. Apply the Session Closing rules from CLAUDE.md:
1. Append any decisions made to daily/${TODAY}.md under ## Decisions
2. Update active project READMEs if next actions changed
3. Update people/ logs if anyone was discussed
4. Note any _inbox/ items that got processed

Do this now without asking. If nothing of substance happened, exit silently."

jq -n --arg ctx "$DIRECTIVE" \
  '{hookSpecificOutput: {hookEventName: "Stop", additionalContext: $ctx}}'
