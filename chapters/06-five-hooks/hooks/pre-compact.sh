#!/usr/bin/env bash
# pre-compact.sh - Chapter 6 (ch06:272-286, appendices:184-198).
# Asks Claude to write decisions into today's daily note before compaction.
# Install at .claude/hooks/pre-compact.sh in YOUR vault. Book-verbatim.
set -euo pipefail

TODAY=$(date +%Y-%m-%d)
DIRECTIVE="Before compacting, scan this session for decisions made (per the
Decision Log Pointer rule in CLAUDE.md). For each decision, append a bullet
to daily/${TODAY}.md under a ## Decisions heading. Format:
'- HH:MM Decision: <one-line summary>. Reasoning: <one sentence>.'
If no decisions were made in this session, do nothing. Do not ask
permission; just write the file."

jq -n --arg ctx "$DIRECTIVE" \
  '{hookSpecificOutput: {hookEventName: "PreCompact", additionalContext: $ctx}}'
