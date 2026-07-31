#!/usr/bin/env bash
# link-check-fixed.sh - Appendix B3, repaired. Finds dead [[wikilinks]] and
# dead relative markdown links in a vault.
#
# The book's version is next door as link-check.sh, byte-identical to the page.
# It reports two kinds of link that are perfectly healthy:
#
#   (a) any [[wikilink]] pointing at a note in _archive/. The find at B3
#       excludes _archive/ from the TARGET search, but the prose under the
#       script describes skipping archived SOURCES. Link an archived note from
#       an active one - which is the whole reason archive is not delete - and
#       the checker calls it dead.
#   (b) any relative link inside a subfolder. B3 tests `-f "$path"` from the
#       vault root, so [decisions](decisions.md) written inside
#       projects/exports-api/ is tested as <vault>/decisions.md and fails.
#
# Diagnostic question 1 trips at "more than 5", so a healthy vault crosses the
# threshold on its own false positives. Fixes: search _archive/ for targets,
# and resolve a relative link from the folder of the file that contains it.
#
# Usage:  ./link-check-fixed.sh [vault-path]
# Default is ../.. relative to this script, matching the book's
# scripts/link-check.sh placement at the vault root.
set -euo pipefail

VAULT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
[[ -d "$VAULT" ]] || { echo "not a directory: $VAULT" >&2; exit 1; }
cd "$VAULT"

echo "=== Dead wikilinks ==="
# grep exits 1 when it matches nothing, and `set -e` plus pipefail would abort
# the script right here on a vault that simply has no wikilinks yet. A vault
# with no dead links is the goal, not an error, so swallow the empty case.
{ grep -rEoh '\[\[([^]|]+)(\|[^]]+)?\]\]' --include='*.md' . 2>/dev/null || true; } \
  | sed -E 's/\[\[([^]|]+).*\]\]/\1/' \
  | sort -u \
  | while read -r target; do
      [[ -n "$target" ]] || continue
      found="$(find . -name "${target}.md" -not -path "./.obsidian/*" | head -1)"
      if [[ -z "$found" ]]; then
        echo "  $target"
      fi
    done

echo "=== Dead path links ==="
# same guard as above, and this one bit harder: it is the last statement in the
# script, so an empty match made the whole script exit 1. A vault written the
# way this book teaches uses [[wikilinks]] and may have no ](file.md) links at
# all, which made vault-diagnostic.sh die silently on a perfectly good vault.
{ grep -rEo '\]\([^)]+\.md\)' --include='*.md' . 2>/dev/null || true; } \
  | sed -E 's#^(.+):\]\(([^)]+\.md)\)$#\1|\2#' \
  | sort -u \
  | while IFS='|' read -r src path; do
      [[ -n "${path:-}" ]] || continue
      case "$path" in
        /*|*://*) continue ;;          # absolute and external, not ours to check
      esac
      # a link counts as live if it resolves from the file that holds it,
      # which is what Obsidian writes, or from the vault root, which is what
      # people type by hand
      [[ -f "$(dirname "$src")/$path" ]] && continue
      [[ -f "$path" ]] && continue
      echo "  $path  (linked from ${src#./})"
    done
