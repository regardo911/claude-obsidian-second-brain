#!/usr/bin/env bash
# Appendix B3, book-verbatim. Install at scripts/link-check.sh in YOUR vault.
# It reports two kinds of healthy link as dead - see ./link-check-fixed.sh.
# scripts/link-check.sh - find dead links in the vault
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== Dead wikilinks ==="
grep -rEoh '\[\[([^]|]+)(\|[^]]+)?\]\]' --include='*.md' . \
  | sed -E 's/\[\[([^]|]+).*\]\]/\1/' \
  | sort -u \
  | while read -r target; do
      found="$(find . -name "${target}.md" -not -path "./.obsidian/*" -not -path "./_archive/*" | head -1)"
      if [[ -z "$found" ]]; then
        echo "  $target"
      fi
    done

echo "=== Dead path links ==="
grep -rEohn '\]\([^)]+\.md\)' --include='*.md' . \
  | sed -E 's/.*\]\(([^)]+\.md)\).*/\1/' \
  | sort -u \
  | while read -r path; do
      if [[ ! -f "$path" ]]; then
        echo "  $path"
      fi
    done
