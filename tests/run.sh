#!/usr/bin/env bash
# tests/run.sh - runs everything in this repo that can be run without Claude
# Code. No network, no keys, no config. Needs bash, jq and Python 3.9+.
#
# The interesting half is the book-bug assertions. For each of the three bugs
# the suite asserts the broken behaviour on the book-verbatim artifact AND its
# absence on the repaired one. Asserting only the repair would let "fixed" mean
# whatever the repair happens to do.
#
# Nothing here touches the five skills or the three subagents. Those are
# prompts Claude executes; a test that pretended to run one would be testing a
# mock of Claude.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS="$ROOT/chapters/06-five-hooks/hooks"
FIXED="$ROOT/chapters/06-five-hooks/hooks-fixed"
FIX="$ROOT/chapters/06-five-hooks/fixtures"
DIAG="$ROOT/chapters/11-diagnostic"
PASS=0; FAIL=0

command -v jq >/dev/null 2>&1 || { echo "jq is required: brew install jq / apt install jq / winget install jqlang.jq" >&2; exit 1; }
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,9) else 1)' \
  || { echo "Python 3.9+ is required (post-tool-use.py uses str.removeprefix)" >&2; exit 1; }

ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL %s\n       %s\n' "$1" "$2"; }
has()  { case "$2" in *"$1"*) return 0 ;; *) return 1 ;; esac; }

assert_has()     { if has "$2" "$3"; then ok "$1"; else bad "$1" "expected to find: $2"; fi; }
assert_lacks()   { if has "$2" "$3"; then bad "$1" "expected NOT to find: $2"; else ok "$1"; fi; }
assert_eq()      { if [[ "$2" == "$3" ]]; then ok "$1"; else bad "$1" "expected [$2] got [$3]"; fi; }
assert_empty()   { if [[ -z "$2" ]]; then ok "$1"; else bad "$1" "expected no output, got [$2]"; fi; }
assert_nonempty(){ if [[ -n "$2" ]]; then ok "$1"; else bad "$1" "expected output, got none"; fi; }

section() { printf '\n%s\n' "$1"; }

VAULT="$(mktemp -d)"; trap 'rm -rf "$VAULT" "$AGED"' EXIT
cp -R "$ROOT/sample-vault/." "$VAULT/"
AGED="$(mktemp -d)"; cp -R "$ROOT/sample-vault/." "$AGED/"
TODAY="$(date +%Y-%m-%d)"
feed() { sed "s|SAMPLE_VAULT|$VAULT|g" "$FIX/$1"; }

echo "running against a throwaway copy of sample-vault"

# ---------------------------------------------------------------- shell style
section "shebangs and shell portability"
while IFS= read -r s; do
  assert_eq "$(basename "$s") has a shebang" "#!/usr/bin/env bash" "$(head -1 "$s")"
done < <(find "$ROOT" -name '*.sh' -not -path '*/.git/*' | sort)
assert_eq "post-tool-use.py has a shebang" "#!/usr/bin/env python3" "$(head -1 "$HOOKS/post-tool-use.py")"

for s in "$FIXED/stop.sh" "$FIXED/user-prompt-submit.sh" "$DIAG/link-check-fixed.sh"; do
  out="$(cd "$VAULT" && CLAUDE_PROJECT_DIR="$VAULT" zsh "$s" "$VAULT" 2>&1)"; rc=$?
  assert_eq "$(basename "$s") runs clean under zsh" "0" "$rc"
done

# ------------------------------------------------------------- 1. SessionStart
section "SessionStart"
out="$(feed session-start.json | CLAUDE_PROJECT_DIR="$VAULT" bash "$HOOKS/session-start.sh")"; rc=$?
assert_eq   "session-start.sh exits 0" "0" "$rc"
assert_eq   "session-start.sh emits valid JSON" "SessionStart" "$(echo "$out" | jq -r '.hookSpecificOutput.hookEventName')"
ctx="$(echo "$out" | jq -r '.hookSpecificOutput.additionalContext')"
assert_nonempty "additionalContext is populated" "$ctx"
assert_has  "additionalContext carries CLAUDE.md" "# Folder Schema" "$ctx"
assert_has  "  and the Active Projects section" "projects/exports-api/" "$ctx"

# The handler reads CLAUDE_PROJECT_DIR and nothing else. The cwd field in the
# stdin payload is ignored entirely - it never reads stdin at all. Worth
# pinning down, because it is why a hook that works in your terminal can inject
# an empty context when Claude Code runs it from a different directory.
out="$(feed session-start.json | (cd /tmp && bash "$HOOKS/session-start.sh"))"
ctx2="$(echo "$out" | jq -r '.hookSpecificOutput.additionalContext')"
assert_lacks "ignores the cwd in the payload — only CLAUDE_PROJECT_DIR counts" "# Folder Schema" "$ctx2"

out="$(cd /tmp && CLAUDE_PROJECT_DIR=/nonexistent-vault bash "$HOOKS/session-start.sh")"; rc=$?
assert_eq "session-start.sh survives a missing CLAUDE.md" "0" "$rc"
assert_eq "  and still emits valid JSON" "SessionStart" "$(echo "$out" | jq -r '.hookSpecificOutput.hookEventName')"

# -------------------------------------------------- 2. UserPromptSubmit, bug 1
section "UserPromptSubmit — book-bug #1 (awk never matches the book's CLAUDE.md)"
book="$(CLAUDE_PROJECT_DIR="$VAULT" bash "$HOOKS/user-prompt-submit.sh" | jq -r '.hookSpecificOutput.additionalContext')"
fixd="$(CLAUDE_PROJECT_DIR="$VAULT" bash "$FIXED/user-prompt-submit.sh" | jq -r '.hookSpecificOutput.additionalContext')"
assert_has   "BUG present: book version injects a blank active project" "- Active project: " "$book$(printf '\n')"
assert_lacks "BUG present: book version never finds the slug"          "exports-api" "$book"
assert_has   "FIXED: repaired version finds the slug"                  "- Active project: exports-api" "$fixd"
assert_has   "both still emit the five-folder reminder"                "5 folders only" "$fixd"

# a CLAUDE.md in the shape the book's awk DOES expect, to show the awk is not
# broken in general, only against the CLAUDE.md the book itself prints
SHAPED="$(mktemp -d)"
printf '## Active Projects\n\n- `projects/shaped-demo/` — x\n' > "$SHAPED/CLAUDE.md"
book2="$(CLAUDE_PROJECT_DIR="$SHAPED" bash "$HOOKS/user-prompt-submit.sh" | jq -r '.hookSpecificOutput.additionalContext')"
assert_has "book version works on '## Active Projects' + backticks" "- Active project: shaped-demo" "$book2"
fix2="$(CLAUDE_PROJECT_DIR="$SHAPED" bash "$FIXED/user-prompt-submit.sh" | jq -r '.hookSpecificOutput.additionalContext')"
assert_has "repaired version handles that shape too" "- Active project: shaped-demo" "$fix2"
rm -rf "$SHAPED"

# --------------------------------------------------------------- 3. PostToolUse
section "PostToolUse"
rm -f "$VAULT/daily/$TODAY.md"
feed post-tool-use-file-path.json | python3 "$HOOKS/post-tool-use.py"; rc=$?
assert_eq  "post-tool-use.py exits 0 on tool_input.file_path" "0" "$rc"
assert_has "  creates today's daily note with the heading" "## Vault Activity" "$(cat "$VAULT/daily/$TODAY.md")"
assert_has "  logs the path relative to the vault" 'Write: `projects/exports-api/decisions.md`' "$(cat "$VAULT/daily/$TODAY.md")"

feed post-tool-use-path.json | python3 "$HOOKS/post-tool-use.py"; rc=$?
assert_eq  "post-tool-use.py exits 0 on tool_input.path" "0" "$rc"
assert_has "  handles the .path fallback" 'Edit: `projects/exports-api/notes.md`' "$(cat "$VAULT/daily/$TODAY.md")"

feed post-tool-use-no-path.json | python3 "$HOOKS/post-tool-use.py"; rc=$?
assert_eq  "post-tool-use.py exits 0 when neither key is present" "0" "$rc"
assert_has "  logs ? rather than crashing" 'Edit: `?`' "$(cat "$VAULT/daily/$TODAY.md")"
assert_eq  "  appends, never rewrites (3 entries)" "3" "$(grep -c '^- ' "$VAULT/daily/$TODAY.md")"

cp "$FIX/daily-no-heading.md" "$VAULT/daily/$TODAY.md"
feed post-tool-use-file-path.json | python3 "$HOOKS/post-tool-use.py"
assert_has "adds ## Vault Activity to a note that /daily made first" "## Vault Activity" "$(cat "$VAULT/daily/$TODAY.md")"
assert_has "  and leaves /daily's sections alone" "## Intent" "$(cat "$VAULT/daily/$TODAY.md")"

# ----------------------------------------------------------------- 4. PreCompact
section "PreCompact"
out="$(bash "$HOOKS/pre-compact.sh")"; rc=$?
assert_eq  "pre-compact.sh exits 0" "0" "$rc"
assert_eq  "  emits valid JSON" "PreCompact" "$(echo "$out" | jq -r '.hookSpecificOutput.hookEventName')"
assert_has "  names today's daily note in the directive" "daily/${TODAY}.md" "$(echo "$out" | jq -r '.hookSpecificOutput.additionalContext')"

# ---------------------------------------------------------- 5. Stop, book-bug 2
section "Stop — book-bug #2 (grep -c prints 0 and exits 1, so ACTIVITY is \"0\\n0\")"
rm -f "$VAULT/daily/$TODAY.md"
out="$(CLAUDE_PROJECT_DIR="$VAULT" bash "$HOOKS/stop.sh" 2>/dev/null)"
assert_empty "no daily note at all: book version stays silent" "$out"
out="$(CLAUDE_PROJECT_DIR="$VAULT" bash "$FIXED/stop.sh" 2>/dev/null)"
assert_empty "no daily note at all: repaired version stays silent" "$out"

for state in daily-no-heading daily-no-activity; do
  cp "$FIX/$state.md" "$VAULT/daily/$TODAY.md"
  err="$(mktemp)"
  out="$(CLAUDE_PROJECT_DIR="$VAULT" bash "$HOOKS/stop.sh" 2>"$err")"
  assert_nonempty "BUG present ($state): book version injects the closer anyway" "$out"
  assert_has      "BUG present ($state): bash reports an arithmetic error" "syntax error" "$(cat "$err")"
  zrc=0; CLAUDE_PROJECT_DIR="$VAULT" zsh "$HOOKS/stop.sh" >/dev/null 2>&1 || zrc=$?
  assert_eq       "BUG present ($state): under zsh the book version dies" "1" "$zrc"
  rm -f "$err"

  err="$(mktemp)"
  out="$(CLAUDE_PROJECT_DIR="$VAULT" bash "$FIXED/stop.sh" 2>"$err")"; rc=$?
  assert_empty "FIXED ($state): repaired version stays silent" "$out"
  assert_eq    "FIXED ($state): exits 0" "0" "$rc"
  assert_empty "FIXED ($state): nothing on stderr" "$(cat "$err")"
  rm -f "$err"
done

cp "$FIX/daily-with-activity.md" "$VAULT/daily/$TODAY.md"
out="$(CLAUDE_PROJECT_DIR="$VAULT" bash "$FIXED/stop.sh" 2>/dev/null)"
assert_eq  "real activity: repaired version DOES inject" "Stop" "$(echo "$out" | jq -r '.hookSpecificOutput.hookEventName')"
assert_has "  and the directive names today's note" "daily/${TODAY}.md" "$(echo "$out" | jq -r '.hookSpecificOutput.additionalContext')"

# ------------------------------------------------------ link check, book-bug 3
section "link-check — book-bug #3 (two classes of false positive)"
cp -R "$ROOT/sample-vault/." "$VAULT/" 2>/dev/null
mkdir -p "$VAULT/scripts"; cp "$DIAG/link-check.sh" "$VAULT/scripts/"
book="$(bash "$VAULT/scripts/link-check.sh")"
fixd="$(bash "$DIAG/link-check-fixed.sh" "$VAULT")"

assert_has   "BUG present: book version calls an ARCHIVED note dead" "retired-pricing-call" "$book"
assert_lacks "FIXED: repaired version does not"                      "retired-pricing-call" "$fixd"
assert_has   "BUG present: book version calls a same-folder link dead" "decisions.md" "$book"
assert_lacks "FIXED: repaired version does not"                        "decisions.md" "$fixd"

for dead in exports-api-retro oncall-runbook priya-1on1-2026-05-03 q3-pricing-brief rate-limit-postmortem zenith-scope-v2; do
  assert_has "genuinely dead wikilink still caught: $dead" "$dead" "$fixd"
done
assert_has "genuinely dead relative link still caught" "retro-2026-04.md" "$fixd"

n_book=$(echo "$book" | awk '/Dead wikilinks/{f=1;next} /^===/{f=0} f && NF' | wc -l | tr -d ' ')
n_fixd=$(echo "$fixd" | awk '/Dead wikilinks/{f=1;next} /^===/{f=0} f && NF' | wc -l | tr -d ' ')
assert_eq "book version reports 7 dead wikilinks (6 real + 1 false)" "7" "$n_book"
assert_eq "repaired version reports 6, all real"                     "6" "$n_fixd"

# ----------------------------------------------------------------- diagnostic
section "vault-diagnostic — thresholds"
out="$(bash "$DIAG/vault-diagnostic.sh" "$VAULT")"; rc=$?
assert_eq  "exits 0" "0" "$rc"
assert_has "Q1 crossed on the sample vault (6 > 5)"  "| 1 | Dead \`[[wikilinks]]\` | more than 5 | 6 | **CROSSED** |" "$out"
assert_has "Q2 under threshold (2 of 3 captures are old)" "| more than 3 | 2 | under threshold |" "$out"
assert_has "Q3 under threshold on clone-fresh mtimes"     "| more than 2 | 0 | under threshold |" "$out"
assert_has "Q4 prints unknown, never a number"       "| more than 10 | unknown | needs Claude Code |" "$out"
assert_lacks "Q4 does not print the book's '5 high-confidence' figure" "high-confidence and 2" "$out"
assert_has "clone-mtime caveat shown when every file shares a date" "fresh \`git clone\` looks like" "$out"
assert_has "fix plan names the crossed question" "**Dead links.**" "$out"
assert_has "fix plan tells you how to keep it" "_archive/diagnostics/" "$out"
assert_has "counts the crossings correctly" "1 of 5 questions crossed" "$out"

before="$(find "$VAULT" -type f | sort | md5 2>/dev/null || find "$VAULT" -type f | sort | md5sum)"
bash "$DIAG/vault-diagnostic.sh" "$VAULT" >/dev/null
after="$(find "$VAULT" -type f | sort | md5 2>/dev/null || find "$VAULT" -type f | sort | md5sum)"
assert_eq "the diagnostic is read-only — no file added or removed" "$before" "$after"

assert_eq "refuses to run with no vault argument" "2" "$(bash "$DIAG/vault-diagnostic.sh" >/dev/null 2>&1; echo $?)"
assert_eq "refuses a path that is not a directory" "1" "$(bash "$DIAG/vault-diagnostic.sh" /nope/not/here >/dev/null 2>&1; echo $?)"

section "vault-diagnostic — the date questions, on an aged vault"
# git does not preserve mtimes, so the only honest way to exercise Q3 and Q5 is
# to create the condition here rather than commit a vault that pretends to have
# one. Q2 reads the ISO date in each filename, so it needs no touching.
mkdir -p "$AGED/projects/dormant-a" "$AGED/projects/dormant-b"
echo "# a" > "$AGED/projects/dormant-a/README.md"
echo "# b" > "$AGED/projects/dormant-b/README.md"
for n in a b c d e; do echo "# stale $n" > "$AGED/_inbox/2026-01-0$n-stale.md" 2>/dev/null || true; done
for n in 1 2 3 4 5; do echo "# stale $n" > "$AGED/_inbox/2026-01-0$n-stale.md"; done
find "$AGED/projects" -exec touch -t 202601010000 {} \; 2>/dev/null
touch -t 202601010000 "$AGED/CLAUDE.md"
out="$(bash "$DIAG/vault-diagnostic.sh" "$AGED")"
assert_has "Q2 crosses when 7 captures are older than 7 days" "| more than 3 | 7 | **CROSSED** |" "$out"
assert_has "Q3 crosses when 4 projects are untouched 30 days" "| more than 2 | 4 | **CROSSED** |" "$out"
assert_has "Q5 crosses on a stale CLAUDE.md"                  "days ago | **CROSSED** |" "$out"
assert_has "Q4 is still unknown on an aged vault"             "unknown | needs Claude Code |" "$out"
assert_has "fix plan lists the stale captures by name"        "2026-01-01-stale.md" "$out"
assert_has "clone-mtime caveat correctly absent"              "## Fix plan" "$out"
assert_lacks "  (no caveat once mtimes actually vary)"        "fresh \`git clone\` looks like" "$out"
assert_has "counts 4 of 5 crossed"                            "4 of 5 questions crossed" "$out"

# ------------------------------------------------------------------ make-vault
section "make-vault"
T="$(mktemp -d)"
bash "$ROOT/chapters/04-build-the-vault/make-vault.sh" "$T/fresh" >/dev/null 2>&1
assert_eq "creates the five folders" "5" "$(find "$T/fresh" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
assert_eq "a README in each"          "5" "$(find "$T/fresh" -name README.md | wc -l | tr -d ' ')"
assert_has "READMEs are the book's"   "Capture-first folder." "$(cat "$T/fresh/_inbox/README.md")"
assert_eq "writes no CLAUDE.md — that is Chapter 5" "0" "$(find "$T/fresh" -name 'CLAUDE.md' | wc -l | tr -d ' ')"

rc=0; bash "$ROOT/chapters/04-build-the-vault/make-vault.sh" "$T/fresh" >/dev/null 2>&1 || rc=$?
assert_eq "refuses a non-empty directory without --yes" "1" "$rc"
rc=0; bash "$ROOT/chapters/04-build-the-vault/make-vault.sh" "$T/fresh" --yes >/dev/null 2>&1 || rc=$?
assert_eq "proceeds with --yes" "0" "$rc"
rc=0; bash "$ROOT/chapters/04-build-the-vault/make-vault.sh" >/dev/null 2>&1 || rc=$?
assert_eq "refuses with no argument" "2" "$rc"
rm -rf "$T"

# ------------------------------------------------- vault shapes that are not ours
# sample-vault happens to contain both a dead wikilink and a dead relative link,
# so every check above passes without ever asking what happens on a vault that
# has neither. That gap hid a real one: grep exits 1 when it matches nothing,
# and the trailing grep in link-check-fixed.sh is the script's last statement,
# so it returned 1 and vault-diagnostic.sh died under set -e printing nothing.
# A vault written the way this book teaches uses [[wikilinks]] and may well have
# no ](file.md) links at all. Run the tools on vaults they were not built around.
section "other vault shapes (empty · wikilinks only · path links only)"
SHAPES="$(mktemp -d)"
for shape in empty wikionly pathonly; do
  mkdir -p "$SHAPES/$shape"/{_inbox,projects,daily,people,_archive}
  printf '# Identity\n' > "$SHAPES/$shape/CLAUDE.md"
done
printf 'a note that links [[Missing]]\n'   > "$SHAPES/wikionly/projects/a.md"
printf 'a note that links [x](nope.md)\n'  > "$SHAPES/pathonly/projects/b.md"
for shape in empty wikionly pathonly; do
  bash "$DIAG/link-check-fixed.sh" "$SHAPES/$shape" >/dev/null 2>&1
  assert_eq "link-check-fixed exits 0 on a $shape vault" "0" "$?"
  out="$(bash "$DIAG/vault-diagnostic.sh" "$SHAPES/$shape" 2>/dev/null)"
  assert_eq "vault-diagnostic exits 0 on a $shape vault" "0" "$?"
  assert_has "vault-diagnostic still prints its table on a $shape vault" \
    "| 1 | Dead" "$out"
done
rm -rf "$SHAPES"

# ------------------------------------------------------------------- structure
section "structure"
assert_eq "no .claude/ directory anywhere in the repo" "0" \
  "$(find "$ROOT" -name '.claude' -not -path '*/.git/*' | wc -l | tr -d ' ')"
assert_eq "exactly 4 images in docs/images" "4" "$(find "$ROOT/docs/images" -name '*.png' | wc -l | tr -d ' ')"
assert_eq "no mermaid blocks" "0" "$(grep -rl '```mermaid' "$ROOT" --include='*.md' 2>/dev/null | wc -l | tr -d ' ')"
assert_eq "no DISCLAIMER.md" "0" "$(find "$ROOT" -name 'DISCLAIMER.md' | wc -l | tr -d ' ')"
assert_eq "MIT LICENSE present" "1" "$(find "$ROOT" -maxdepth 1 -name 'LICENSE' | wc -l | tr -d ' ')"

# ------------------------------------------------------------------------ done
printf '\n%s\n' "-----------------------------------------------"
printf '%d assertions, %d passed, %d failed\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then exit 1; fi
if [[ "$PASS" -eq 0 ]]; then echo "no assertions ran — that is a failure, not a pass"; exit 1; fi
echo "green. Note: the 5 skills and 3 subagents are not covered here and cannot be."
