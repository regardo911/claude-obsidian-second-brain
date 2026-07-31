#!/usr/bin/env bash
# vault-diagnostic.sh - Chapter 11 / Appendix B1. The five-question vault
# diagnostic, run against a real vault, with the book's exact thresholds.
#
# Usage:  ./vault-diagnostic.sh <vault-path>
#
# Read-only. It counts and prints; it never writes to the vault you hand it.
# The book says to save the plan at _archive/diagnostics/<today>.md, so the
# output is markdown and the last line tells you the redirect to do it.
#
# Question 4 needs the cross-linker subagent, which needs Claude Code and a
# model. A shell script cannot run it, so question 4 prints "unknown" and asks
# you for the number. It will never print a count it did not measure.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
VAULT="${1:-}"

if [[ -z "$VAULT" ]]; then
  cat >&2 <<EOF
usage: $(basename "$0") <vault-path>

  $(basename "$0") ~/vault                    your own vault
  $(basename "$0") "$HERE/../../sample-vault" the sample vault in this repo
EOF
  exit 2
fi
[[ -d "$VAULT" ]] || { echo "not a directory: $VAULT" >&2; exit 1; }
VAULT="$(cd "$VAULT" && pwd)"

TODAY="$(date +%Y-%m-%d)"
NOW="$(date +%s)"
CROSSED=0

days_since_epoch() { echo $(( (NOW - $1) / 86400 )); }
mtime_epoch()      { date -r "$1" +%s; }
iso_epoch()        { date -j -f "%Y-%m-%d" "$1" +%s 2>/dev/null || date -d "$1" +%s 2>/dev/null; }

# Verdicts are computed up front, never inside the heredoc below. A $(...) in
# a heredoc runs in a subshell, so a counter incremented in there is thrown
# away - which is how the first version of this script printed a CROSSED row
# and "nothing crossed a threshold" in the same report.
plural()  { [[ "$1" -eq 1 ]] && echo "$2" || echo "${2}s"; }
verdict() { if [[ "$1" -gt "$2" ]]; then echo "**CROSSED**"; else echo "under threshold"; fi; }
tally()   { [[ "$1" -gt "$2" ]] && CROSSED=$((CROSSED + 1)); return 0; }

# --- Q1: dead wikilinks -----------------------------------------------------
# Delegated to link-check-fixed.sh so there is one implementation of the rule.
# The book's own link-check.sh reports archived targets and subfolder-relative
# links as dead, which would trip this question on a healthy vault.
LC_OUT="$(bash "$HERE/link-check-fixed.sh" "$VAULT")"
Q1=$(echo "$LC_OUT" | awk '/^=== Dead wikilinks/{f=1;next} /^===/{f=0} f && NF' | wc -l | tr -d ' ')
Q1_PATHS=$(echo "$LC_OUT" | awk '/^=== Dead path links/{f=1;next} /^===/{f=0} f && NF' | wc -l | tr -d ' ')

# --- Q2: _inbox/ items older than 7 days ------------------------------------
# A capture written by /capture is named _inbox/<ISO date>-<slug>.md, so the
# filename carries the creation date. Fall back to mtime when it does not -
# and note that git does not preserve mtimes, so a freshly cloned vault looks
# brand new to every mtime question below.
Q2=0
Q2_LIST=""
if [[ -d "$VAULT/_inbox" ]]; then
  while IFS= read -r f; do
    base="$(basename "$f")"
    [[ "$base" == "README.md" ]] && continue
    if [[ "$base" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
      age=$(days_since_epoch "$(iso_epoch "${BASH_REMATCH[1]}")")
    else
      age=$(days_since_epoch "$(mtime_epoch "$f")")
    fi
    if [[ "$age" -gt 7 ]]; then
      Q2=$((Q2 + 1))
      Q2_LIST="${Q2_LIST}  - \`_inbox/${base}\` — ${age} days old"$'\n'
    fi
  done < <(find "$VAULT/_inbox" -maxdepth 1 -type f -name '*.md')
fi

# --- Q3: projects/ subfolders untouched for 30 days -------------------------
Q3=0
Q3_LIST=""
if [[ -d "$VAULT/projects" ]]; then
  while IFS= read -r d; do
    newest=0
    while IFS= read -r f; do
      e=$(mtime_epoch "$f"); [[ "$e" -gt "$newest" ]] && newest=$e
    done < <(find "$d" -type f)
    [[ "$newest" -eq 0 ]] && newest=$(mtime_epoch "$d")
    age=$(days_since_epoch "$newest")
    if [[ "$age" -gt 30 ]]; then
      Q3=$((Q3 + 1))
      Q3_LIST="${Q3_LIST}  - \`projects/$(basename "$d")/\` — untouched ${age} days"$'\n'
    fi
  done < <(find "$VAULT/projects" -mindepth 1 -maxdepth 1 -type d)
fi

# --- Q5: CLAUDE.md freshness ------------------------------------------------
if [[ -f "$VAULT/CLAUDE.md" ]]; then
  Q5=$(days_since_epoch "$(mtime_epoch "$VAULT/CLAUDE.md")")
  Q5_LINES=$(wc -l < "$VAULT/CLAUDE.md" | tr -d ' ')
else
  Q5=-1
fi

# How many distinct calendar days of mtime does this vault have? One means
# every file was stamped at the same moment, which is what git does on clone.
# Questions 3 and 5 read mtimes, so on a fresh clone they are meaningless and
# the report says so instead of reporting a reassuring zero.
# written as a read loop rather than `find -exec date -r {} +%F \;` because
# that form exits 1 on BSD find even when it prints every line, and pipefail
# then takes the whole script down
MTIME_DAYS=$(
  while IFS= read -r f; do date -r "$f" +%F; done \
    < <(find "$VAULT" -type f -name '*.md') | sort -u | wc -l
)
MTIME_DAYS="$(echo "$MTIME_DAYS" | tr -d ' ')"

tally "$Q1" 5
tally "$Q2" 3
tally "$Q3" 2
[[ "$Q5" -lt 0 ]] && CROSSED=$((CROSSED + 1)) || tally "$Q5" 90

# --- report -----------------------------------------------------------------
cat <<EOF
# Vault diagnostic — $TODAY

Vault: \`$VAULT\`
Thresholds are the book's (Chapter 11 / Appendix B1). Crossing one means fix
it now; staying under means monitor and pick it up at the next weekly review.

| # | Question | Threshold | Measured | Verdict |
|---|---|---|---|---|
| 1 | Dead \`[[wikilinks]]\` | more than 5 | $Q1 | $(verdict "$Q1" 5) |
| 2 | \`_inbox/\` items older than 7 days | more than 3 | $Q2 | $(verdict "$Q2" 3) |
| 3 | \`projects/\` subfolders untouched 30 days | more than 2 | $Q3 | $(verdict "$Q3" 2) |
| 4 | cross-linker missing-link suggestions | more than 10 | unknown | needs Claude Code |
EOF

if [[ "$Q5" -lt 0 ]]; then
  echo "| 5 | \`CLAUDE.md\` last touched | more than 90 days | no CLAUDE.md at vault root | **CROSSED** |"
else
  echo "| 5 | \`CLAUDE.md\` last touched | more than 90 days | $Q5 days ago | $(verdict "$Q5" 90) |"
fi

if [[ "$MTIME_DAYS" -le 1 ]]; then
  echo
  echo "> Every markdown file here shares one modification date. That is what a"
  echo "> fresh \`git clone\` looks like — git restores contents, not timestamps."
  echo "> Questions 3 and 5 read mtimes, so treat their rows as not-yet-measured"
  echo "> on this vault. Question 1 reads file contents and question 2 reads the"
  echo "> ISO date in each capture's filename, so both are true regardless."
fi

echo
echo "## Fix plan"
echo

if [[ "$Q1" -gt 5 ]]; then
  echo "- [ ] **Dead links.** $Q1 dead wikilinks, $Q1_PATHS dead relative $(plural "$Q1_PATHS" link). Repair the targets, then re-run this diagnostic. (Appendix B1 says to run the cross-linker here; cross-linker finds *missing* links and will not touch these — Chapter 11 gets it right and names the link script.)"
  echo '      Full list: `./link-check-fixed.sh '"$VAULT"'`'
elif [[ "$Q1" -gt 0 ]]; then
  echo "- [ ] Dead links are under threshold ($Q1 wikilinks, $Q1_PATHS relative). Fold the fixes into the next weekly review."
fi

if [[ "$Q2" -gt 3 ]]; then
  echo "- [ ] **Process the inbox now.** $Q2 items have been sitting longer than 7 days:"
  printf '%s' "$Q2_LIST"
  echo '      Run `/process-inbox` in Claude Code and route each one.'
elif [[ "$Q2" -gt 0 ]]; then
  echo "- [ ] $Q2 stale inbox item(s), under threshold. Route them at the next weekly review."
fi

if [[ "$Q3" -gt 2 ]]; then
  echo "- [ ] **Archive stale projects.** $Q3 have not moved in 30 days:"
  printf '%s' "$Q3_LIST"
  echo '      Move each to `_archive/projects/<name>/` and drop it from CLAUDE.md Active Projects.'
elif [[ "$Q3" -gt 0 ]]; then
  echo "- [ ] $Q3 stale project(s), under threshold. Decide active-or-archive at the quarterly schema review."
fi

echo "- [ ] **Question 4 is yours to run.** In Claude Code, in this vault: *Run the cross-linker subagent.* Read the count it reports at \`_archive/cross-link-suggestions.md\`. More than 10 means an hour reviewing the high-confidence ones."

if [[ "$Q5" -lt 0 ]]; then
  echo "- [ ] **No \`CLAUDE.md\` at the vault root.** Nothing loads on SessionStart. Start from \`chapters/05-claude-md/CLAUDE.template.md\`."
elif [[ "$Q5" -gt 90 ]]; then
  echo "- [ ] **Refresh \`CLAUDE.md\`.** Last touched $Q5 days ago, currently $Q5_LINES lines. Update Active Projects first; that is the section that goes stale. Target is 80 to 150 lines."
fi

echo
if [[ "$CROSSED" -eq 0 ]]; then
  echo "Nothing crossed a threshold. The vault is in good shape; keep the monthly run as a baseline."
else
  echo "$CROSSED of 5 questions crossed. Work the checked items above at your next session."
fi
echo
echo "---"
echo "Keep this: \`./$(basename "$0") $VAULT > $VAULT/_archive/diagnostics/$TODAY.md\`"
echo "(make the folder first: \`mkdir -p $VAULT/_archive/diagnostics\`)"
