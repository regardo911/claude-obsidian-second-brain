# Chapter 11: the 20-minute diagnostic

This is the folder the repo exists for. Three scripts, all read-only, all
running bare on your own vault.

## What you build

The five-question diagnostic from ch11:77-95 and Appendix B1, as something you
run rather than something you work through by hand.

| # | Question | Threshold | How it's answered |
|---|---|---|---|
| 1 | dead `[[wikilinks]]` | more than 5 | computed, from file contents |
| 2 | `_inbox/` items older than 7 days | more than 3 | computed, from the ISO date in each capture's filename |
| 3 | `projects/` subfolders untouched 30 days | more than 2 | computed, from mtimes |
| 4 | cross-linker missing-link suggestions | more than 10 | **not computed; prints `unknown`** |
| 5 | `CLAUDE.md` last touched | more than 90 days | computed, from mtime |

Question 4 needs the `cross-linker` subagent, which needs Claude Code and a
model. A shell script cannot run one. So it prints `unknown` and tells you the
prompt to type. It will never print a number there, including a plausible one.

## The one command

This is the first thing to run after cloning, and it should be pointed at a
vault you own:

```
./chapters/11-diagnostic/vault-diagnostic.sh ~/your-vault
```

Against the sample vault in this repo, verbatim output:

```
# Vault diagnostic — 2026-07-31

Vault: `/Users/you/claude-obsidian-second-brain/sample-vault`

| # | Question | Threshold | Measured | Verdict |
|---|---|---|---|---|
| 1 | Dead `[[wikilinks]]` | more than 5 | 6 | **CROSSED** |
| 2 | `_inbox/` items older than 7 days | more than 3 | 2 | under threshold |
| 3 | `projects/` subfolders untouched 30 days | more than 2 | 0 | under threshold |
| 4 | cross-linker missing-link suggestions | more than 10 | unknown | needs Claude Code |
| 5 | `CLAUDE.md` last touched | more than 90 days | 0 days ago | under threshold |

> Every markdown file here shares one modification date. That is what a
> fresh `git clone` looks like — git restores contents, not timestamps.
> Questions 3 and 5 read mtimes, so treat their rows as not-yet-measured
> on this vault. Question 1 reads file contents and question 2 reads the
> ISO date in each capture's filename, so both are true regardless.

## Fix plan

- [ ] **Dead links.** 6 dead wikilinks, 1 dead relative link. Repair the targets...
```

That clone-timestamp note is not decoration. Git restores file contents and
not mtimes, so on a fresh clone questions 3 and 5 have nothing to measure and
would otherwise report a reassuring zero. On your real vault, which you have
been editing for months, they measure exactly what they claim.

Question 2 dodges the problem because `/capture` names files
`_inbox/<ISO date>-<slug>.md`, so the creation date is in the filename. That
is also the argument for using `/capture` instead of typing notes by hand.

## What success looks like

The last line names a number of crossed thresholds, and the fix plan above it
has a checkbox for each one with the specific files named. Not a score, but a list
of things to do.

The book says to keep the plan at `_archive/diagnostics/<today>.md`. The script
won't write it for you, because a diagnostic that edits the thing it is
diagnosing is a diagnostic you have to trust. The output is markdown, so:

```
mkdir -p ~/your-vault/_archive/diagnostics
./chapters/11-diagnostic/vault-diagnostic.sh ~/your-vault \
  > ~/your-vault/_archive/diagnostics/$(date +%F).md
```

The script prints those two lines at the end, filled in with your path.

## The link checker, twice

`link-check.sh` is Appendix B3, byte for byte under its comment header.
`link-check-fixed.sh` is the same script with two false-positive classes
removed. Run both against the sample vault and diff them:

```
$ ./chapters/11-diagnostic/link-check-fixed.sh sample-vault
=== Dead wikilinks ===
  exports-api-retro
  oncall-runbook
  priya-1on1-2026-05-03
  q3-pricing-brief
  rate-limit-postmortem
  zenith-scope-v2
=== Dead path links ===
  retro-2026-04.md  (linked from projects/exports-api/notes.md)
```

The book's version reports two more: `retired-pricing-call`, which is a real
note sitting in `_archive/`, and `decisions.md`, which is a real file sitting
next to the note that links it.

Both are its own doing. The `find` at appendices:525 excludes `_archive/` from
the **target** search, so linking an archived note from an active one, which is the
entire reason archive is not delete, reads as dead. And relative links are
`-f`-tested from the vault root rather than from the folder of the file holding
them, so `[decisions](decisions.md)` inside `projects/exports-api/` is looked
for at `<vault>/decisions.md`. The prose under the script describes skipping
archived *sources*, which is a different and sensible thing.

It matters because question 1 trips at "more than 5". A healthy vault crosses
the threshold on false positives alone, you go looking for damage that isn't
there, and the second time it happens you stop running the diagnostic. So
`vault-diagnostic.sh` calls the fixed one.

Appendix B1's row 1 also says to fix dead links by running "`cross-linker`
subagent with reverse mode". There is no reverse mode; `cross-linker` finds
*missing* links and explicitly refuses to modify source files (ch08:130-164).
ch11:19-21 gets it right and names the link script, which is what the fix plan
tells you to use.

## Running it on your own vault

```
./chapters/11-diagnostic/vault-diagnostic.sh ~/vault
```

Monthly. Six hours a year of maintenance, all in, if you also do the quarterly
schema review (ch11:99).

If you want the checker inside the vault where the book puts it:

```
mkdir -p ~/vault/scripts
cp chapters/11-diagnostic/link-check-fixed.sh ~/vault/scripts/link-check.sh
chmod +x ~/vault/scripts/link-check.sh
bash ~/vault/scripts/link-check.sh
```

Both checkers default to the vault two directories up from wherever they sit,
which is what makes `<vault>/scripts/link-check.sh` work with no argument. The
fixed one also takes an explicit path, so it works from anywhere.
