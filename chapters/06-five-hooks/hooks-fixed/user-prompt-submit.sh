#!/usr/bin/env bash
# user-prompt-submit.sh - Chapter 6. Re-injects the schema slice on every prompt.
#
# REPAIRED. The unrepaired original sits next door in hooks/, byte-identical to
# the page. Two things in its awk never match the CLAUDE.md the book itself
# prints, so the reminder ships with a blank active project:
#
#   the book's awk wants   ^## Active Projects      (two hashes)
#   the book's CLAUDE.md   # Active Projects        (one hash, appendix A1 / ch05)
#   the book's awk wants   - `projects/...`         (backticked)
#   the book's CLAUDE.md   - projects/...           (bare)
#
# awk then exits 0 with no output, so the `|| echo "none"` never fires either
# and you get "Active project: " with nothing after it. Fixes: accept any
# heading depth, make the backticks optional, default with :- instead of ||.
set -euo pipefail

VAULT="${CLAUDE_PROJECT_DIR:-.}"
ACTIVE=$(awk '/^#+[[:space:]]+Active Projects/{f=1;next} /^#+[[:space:]]/{f=0} f && /^-[[:space:]]+`?projects\//{
  match($0, /projects\/[a-z0-9-]+/);
  print substr($0, RSTART+9, RLENGTH-9); exit
}' "$VAULT/CLAUDE.md" 2>/dev/null || true)
ACTIVE="${ACTIVE:-none}"

REMINDER="VAULT REMINDER:
- 5 folders only: _inbox/, projects/, daily/, people/, _archive/
- Active project: $ACTIVE
- Default destination: _inbox/ if uncertain
- Read the active project README before suggesting work
- Do not invent new top-level folders"

jq -n --arg ctx "$REMINDER" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
