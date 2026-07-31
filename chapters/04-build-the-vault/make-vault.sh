#!/usr/bin/env bash
# make-vault.sh - Chapter 4, steps 3 and 4. Creates the five-folder skeleton
# and drops the book's README into each folder.
#
# Usage:  ./make-vault.sh <target-dir> [--yes]
#
# The whole of step 3 is one line the book prints:
#   mkdir -p _inbox projects daily people _archive
# Run that by hand if you prefer. This script exists for step 4, which is five
# READMEs you would otherwise copy out of the book one at a time, and for the
# guard: it will not write into a directory that already has files in it
# unless you pass --yes. Point it at a live vault by accident and it stops.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-}"
CONFIRM="${2:-}"

if [[ -z "$TARGET" ]]; then
  echo "usage: $(basename "$0") <target-dir> [--yes]" >&2
  echo "  the vault is just a directory; name the one you want" >&2
  exit 2
fi

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

if [[ -n "$(ls -A "$TARGET" 2>/dev/null)" && "$CONFIRM" != "--yes" ]]; then
  cat >&2 <<EOF
$TARGET is not empty.

This script writes a README into each of the five folders and would overwrite
any that are already there. If this is the vault you meant, re-run with --yes:

  $(basename "$0") "$TARGET" --yes
EOF
  exit 1
fi

cd "$TARGET"
mkdir -p _inbox projects daily people _archive

for pair in "_inbox:_inbox-README.md" "projects:projects-README.md" \
            "daily:daily-README.md" "people:people-README.md" \
            "_archive:_archive-README.md"; do
  folder="${pair%%:*}"
  source_file="${pair##*:}"
  cp "$HERE/folder-readmes/$source_file" "$folder/README.md"
done

echo "Vault created at $TARGET"
echo
ls -la
echo
cat <<EOF
Five folders, a README in each. That is Chapter 4 steps 3 and 4 done.

Next, in the book's order:
  1. cd "$TARGET" && claude          start Claude Code inside the vault
  2. ask it to write _inbox/test-vault-check.md, and watch the file appear
  3. Chapter 5 writes CLAUDE.md at the root, which is what makes the vault
     a system instead of a folder

There is deliberately no CLAUDE.md yet. Chapter 5 is where you write one,
because it has to describe your projects, not mine.
EOF
