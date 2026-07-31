#!/usr/bin/env bash
# stop.sh - Chapter 6 (ch06:316-341, appendices:202-227).
# Injects the session-closer directive when the session touched the vault.
# Install at .claude/hooks/stop.sh in YOUR vault. Book-verbatim, and it
# carries a bug: see ../hooks-fixed/stop.sh.
set -euo pipefail

VAULT="${CLAUDE_PROJECT_DIR:-.}"
TODAY=$(date +%Y-%m-%d)
DAILY="$VAULT/daily/${TODAY}.md"

[[ -f "$DAILY" ]] || exit 0

ACTIVITY=$(awk '/^## Vault Activity/{f=1;next} /^## /{f=0} f' "$DAILY" \
  | grep -c '^- ' || echo 0)

[[ "$ACTIVITY" -eq 0 ]] && exit 0

DIRECTIVE="Session ending. Apply the Session Closing rules from CLAUDE.md:
1. Append any decisions made to daily/${TODAY}.md under ## Decisions
2. Update active project READMEs if next actions changed
3. Update people/ logs if anyone was discussed
4. Note any _inbox/ items that got processed

Do this now without asking. If nothing of substance happened, exit silently."

jq -n --arg ctx "$DIRECTIVE" \
  '{hookSpecificOutput: {hookEventName: "Stop", additionalContext: $ctx}}'
