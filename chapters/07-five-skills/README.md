# Chapter 7: the five skills

`/capture` · `/daily` · `/plan` · `/process-inbox` · `/weekly-review`

Six files in [`commands/`](commands/): the five the book prints, plus one
repair.

## Nothing here is tested, and that is not an oversight

Skills are not scripts. They are prompts Claude executes (ch07:31). There is no
way to run `/capture` without Claude Code and a model, and any test in this
repo that claimed to exercise one would be testing a mock of Claude, which
tells you nothing. So `tests/run.sh` doesn't touch this folder.

What you get instead is the six files, correct and ready to drop in. What you
verify is Claude's behaviour, in your vault, by typing the slash command.

⛔ They ship as `commands/`, not `.claude/commands/`, so that cloning this repo
doesn't register five slash commands in it. Install destination is
`.claude/commands/<name>.md` inside **your vault**. Each file says so in its
own header.

## What you build

| File | Slash command | Writes to |
|---|---|---|
| `capture.md` | `/capture <thought>` | `_inbox/<today>-<slug>.md` |
| `daily.md` | `/daily` | `daily/<today>.md` |
| `plan.md` | `/plan` | nothing, prints a priority list |
| `process-inbox.md` | `/process-inbox` | nothing, prints a routing table |
| `weekly-review.md` | `/weekly-review` | `_archive/weekly-reviews/<friday>.md` |
| `daily-fixed.md` | `/daily`, repaired | `daily/<today>.md` |

Naming rules, if you write your own: lowercase, numbers and hyphens only, 64
characters maximum (ch07:21). Aim under 50 lines.

Two of them deliberately refuse to act. `/plan` prints and writes nothing.
`/process-inbox` proposes a destination per file and waits. Auto-moving inbox
items on a model's judgement is how you lose a note, and the friction is the
safety (ch07:178).

## The one command

```
/capture Slack thread about Q3 rollout — links to the PRD
```

typed inside a Claude Code session in your vault. Expected reply, one line:

```
Captured: /Users/you/vault/_inbox/2026-07-31-slack-thread-q3-rollout.md
```

Then open the file. H1 of your input, a `Captured: ` line with today's date in
long form, and your text again as a paragraph.

## What success looks like

The file exists at `_inbox/<ISO date>-<kebab-slug>.md`, the slug came from your
words, and you didn't think about naming it. That last part is the point: after
a week of `/capture` the inbox is consistently named without any effort from
you, which is what lets `/process-inbox` route it predictably later.

There's a second, slower check. `chapters/11-diagnostic/vault-diagnostic.sh`
reads the ISO date out of those filenames to answer "how many inbox items are
older than seven days". Consistent capture names are what make question 2 of
the diagnostic mean anything.

## Why there's a `daily-fixed.md`

`/daily` and the PostToolUse hook race for the same file. If Claude edits
anything before you type `/daily`, the hook has already created
`daily/<today>.md` holding just `## Vault Activity`. The book's `/daily` sees
a file, replies "Daily note exists", and stops, so `## Intent`, `## Done` and
`## Open` never appear, and `/weekly-review` later reads Done and Open sections
that don't exist (ch07:203-206).

`daily-fixed.md` fills in what's missing instead of bailing, and leaves the
hook's section alone. Install one or the other as `.claude/commands/daily.md`;
they can't both own `/daily`.

## Running them on your own vault

```
mkdir -p ~/vault/.claude/commands
cp chapters/07-five-skills/commands/*.md ~/vault/.claude/commands/
rm ~/vault/.claude/commands/daily-fixed.md          # or use it instead:
# cp chapters/07-five-skills/commands/daily-fixed.md ~/vault/.claude/commands/daily.md
```

Restart Claude Code, then run each once. `/capture` writes a file, `/daily`
scaffolds today, `/plan` prints, `/process-inbox` prints a table,
`/weekly-review` writes into `_archive/weekly-reviews/`.

Edit them. These are prompts, not APIs. If `/plan` hedges when you wanted a
decision, sharpen the wording. The book's own note on this is worth the price:
its first `/plan` returned hedged language until "Be opinionated about
priority" went into the prompt (ch07:148).
