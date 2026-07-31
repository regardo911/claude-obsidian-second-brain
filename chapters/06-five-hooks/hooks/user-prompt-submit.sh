#!/usr/bin/env bash
# user-prompt-submit.sh - Chapter 6 (ch06:168-187, appendices:134-153).
# Re-injects the schema slice before every prompt.
# Install at .claude/hooks/user-prompt-submit.sh in YOUR vault. Book-verbatim,
# and it carries a bug: see ../hooks-fixed/user-prompt-submit.sh.
set -euo pipefail

VAULT="${CLAUDE_PROJECT_DIR:-.}"
ACTIVE=$(awk '/^## Active Projects/{f=1;next} /^## /{f=0} f && /^- `projects\//{
  match($0, /projects\/[a-z0-9-]+/);
  print substr($0, RSTART+9, RLENGTH-9); exit
}' "$VAULT/CLAUDE.md" 2>/dev/null || echo "none")

REMINDER="VAULT REMINDER:
- 5 folders only: _inbox/, projects/, daily/, people/, _archive/
- Active project: $ACTIVE
- Default destination: _inbox/ if uncertain
- Read the active project README before suggesting work
- Do not invent new top-level folders"

jq -n --arg ctx "$REMINDER" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
