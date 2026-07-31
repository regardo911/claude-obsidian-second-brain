#!/usr/bin/env bash
# session-start.sh - Chapter 6 (ch06:127-138, appendices:119-130).
# Reads CLAUDE.md at session start and injects it as additionalContext.
# Install at .claude/hooks/session-start.sh in YOUR vault. Book-verbatim.
set -euo pipefail

VAULT="${CLAUDE_PROJECT_DIR:-.}"
CLAUDE_MD=$(cat "$VAULT/CLAUDE.md" 2>/dev/null || echo "")

CONTEXT=$(printf "Vault context loaded.\n\n=== CLAUDE.md ===\n%s" "$CLAUDE_MD")

jq -n --arg ctx "$CONTEXT" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
