# gotchas

things that actually bit while building this, with what they cost. no
speculative ones. if it isn't in here it didn't happen.

## the book's stop.sh injects the closer on sessions that did nothing

found by running it, not reading it. `grep -c '^- '` prints `0` **and** exits 1
when it matches nothing, so the `|| echo 0` fires as well and `ACTIVITY` ends up
as the two-line string `0\n0`:

```
$ printf '# %s\n\n## Vault Activity\n' "$(date +%F)" > daily/$(date +%F).md
$ CLAUDE_PROJECT_DIR=. bash chapters/06-five-hooks/hooks/stop.sh
stop.sh: line 13: [[: 0
0: syntax error in expression (error token is "0")
{ "hookSpecificOutput": { "hookEventName": "Stop", ... } }
```

so the guard reads false and the closer goes out anyway, the exact opposite of
what the guard is for. under zsh it's worse, the hook just dies:

```
$ CLAUDE_PROJECT_DIR=. zsh chapters/06-five-hooks/hooks/stop.sh
stop.sh:13: bad math expression: operator expected at `0'
$ echo $?
1
```

repair in `hooks-fixed/stop.sh`. tests assert both the break and the fix, on
both shells.

## the book's user-prompt-submit.sh never matches the book's own CLAUDE.md

the awk wants `## Active Projects` and backticked `` - `projects/ ``. appendix
A1 and the ch05 worked example both write `# Active Projects` and bare paths.
so it matches nothing, exits 0, which means the `|| echo "none"` fallback
never fires either, and every prompt carries a blank:

```
$ CLAUDE_PROJECT_DIR=sample-vault bash chapters/06-five-hooks/hooks/user-prompt-submit.sh \
    | jq -r '.hookSpecificOutput.additionalContext' | grep Active
- Active project:
```

no error, exit 0, looks fine in a terminal. this one would have shipped
silently for months. repair in `hooks-fixed/`.

## chmod +x .claude/hooks/*.sh misses post-tool-use.py

the recovery card at appendices:627 and the FAQ at ch12:120 both use the `.sh`
glob. four of the five handlers are `.sh`. the fifth is the python one, and it
is the one that writes your daily note. the BUILD STEP at ch06:366 lists all
five by name and is correct.

use `chmod +x .claude/hooks/*`. cost me nothing here because the tests invoke
handlers through `bash`/`python3` explicitly, which is also why a test suite
would never have caught it for you.

## this repo does not ship a .claude/ directory, on purpose

it would otherwise be five hooks, five slash commands and three subagents that
attach themselves to your clone the moment you open it in Claude Code,
including a PostToolUse handler that writes `daily/<today>.md` **inside the
clone** on your first edit. you cloned a companion repo, you didn't ask it to
start logging.

so: `settings.hooks.json`, `hooks/`, `commands/`, `agents/`. every chapter
README names the real install destination and every artifact repeats it in its
own header. the book is on side, as it happens: *"hooks live in settings, not
in a folder"* (ch06:34).

deliberate deviation from the book's layout, and the only one.

## find -exec date -r {} +%F \; exits 1 even when it prints everything

hit while writing the diagnostic's clone-detection. the command prints all 19
dates and returns 1:

```
$ find sample-vault -type f -name '*.md' -exec date -r {} +%F \; | wc -l
      19
```

but under `set -o pipefail` inside a script that non-zero takes the whole run
down, and the script exited silently before printing a single line of its
report. cost about fifteen minutes, most of it spent suspecting my own awk.

rewritten as a plain read loop. i don't know why BSD find does this and haven't
gone looking; the loop is clearer anyway.

## the same pipefail trap again, in link-check-fixed.sh, and this one shipped

caught late, on a vault i built by hand instead of the one in this repo. same
shape as the `find -exec` entry above and i still walked into it: `grep` exits 1
when it matches nothing, and the dead-path-links pipeline is the *last*
statement in `link-check-fixed.sh`, so its status became the script's:

```
$ mkdir -p /tmp/v/{_inbox,projects,daily,people,_archive}
$ printf 'a note that links [[Missing]]\n' > /tmp/v/projects/a.md
$ bash chapters/11-diagnostic/link-check-fixed.sh /tmp/v > /dev/null; echo $?
1
$ bash chapters/11-diagnostic/vault-diagnostic.sh /tmp/v; echo $?
1
```

nothing printed. not one line of the report. and the vault it happens on is the
normal one: this book teaches `[[wikilinks]]`, so a vault can easily have zero
`](file.md)` links and trip it. an empty vault trips it too, on the first grep.

why the tests were green through all of it: `sample-vault/` contains a dead
wikilink *and* a dead relative link, so both greps always matched and neither
empty case was ever exercised. a fixture that is too convenient is worse than no
fixture. `tests/run.sh` now runs both tools against three vaults it wasn't built
around (empty, wikilinks only, path links only) and those nine assertions fail
if you take the guard back out. i checked that they do.

## the diagnostic printed CROSSED and "nothing crossed a threshold"

my bug, in the first draft of `vault-diagnostic.sh`. the verdict function
incremented a counter *inside* a `$(...)` in a heredoc, which runs in a
subshell, so every increment was thrown away:

```
| 1 | Dead [[wikilinks]] | more than 5 | 6 | **CROSSED** |
...
Nothing crossed a threshold. The vault is in good shape;
```

verdicts are computed before the heredoc now. worth naming because the report
looked completely plausible until you read both halves of it.

## git does not preserve mtimes, and three of the five questions read them

clone this repo and run the diagnostic against `sample-vault/` and questions 3
and 5 will report zero days for everything, because git restores contents and
not timestamps. that's not the vault being healthy, it's the vault having no
history to measure.

question 2 dodges it by reading the ISO date out of each capture's filename,
which is exactly the name `/capture` gives them. questions 3 and 5 can't, so
the report prints a note when every file shares one date, and `tests/run.sh`
ages a throwaway copy with `touch -t` rather than committing a vault that
pretends to be old.

on your own vault, which you've been editing for months, all five are real.
