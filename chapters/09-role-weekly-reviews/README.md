# Chapter 9: the role weekly review

Four files in [`commands/`](commands/). You need one.

## What you build

One more skill, on top of Chapter 7's five. Same vault, same hooks, same
subagents. The review is where your role shows up.

| Role | File | Extra structure it expects |
|---|---|---|
| PM | `weekly-review-pm.md` | `projects/sprint-*/`, `people/<report>/meetings/` |
| Founder | `weekly-review-founder.md` | `projects/decisions/` at vault root |
| Freelancer | `weekly-review-freelancer.md` | `scope.md` + `changes.md` per client folder |
| Knowledge worker | `weekly-review-kw.md` | nothing beyond the base five folders |

All four write to `_archive/weekly-reviews/<this-friday>-<role>.md`. All four
read a 7-day window. Pick the closest match and don't author two. A review
you run every Friday beats two you run occasionally.

Between two roles? The book's mapping: solo lawyer → freelancer, research
scientist → knowledge worker, solo SaaS founder → founder plus the freelancer
scope-memory habit (ch09:19).

## The one command

```
/weekly-review-freelancer
```

in your vault, Thursday afternoon before invoices go out. It replies with one
line and a path. Like every skill in this repo, it needs Claude Code, and nothing
here tests it.

## What success looks like

The book's checkpoint is unusually specific and worth holding to (ch09:201):
the review surfaces **at least one item you'd forgotten you wrote** and **at
least one pattern in your week that surprises you**.

The first run will not clear that bar. You have a few days of daily notes, so
the output is thin, and that's arithmetic rather than a broken skill. Run it
anyway. The third run, three weeks in, is where it starts catching things.

One honest note on windows: the ch09 prose introducing the PM review says it
reads the past *two weeks* of meeting notes (ch09:25), while the skill body
right underneath reads *7 days* (ch09:37). The shipped file is the 7-day
version, because the file is the thing that runs. Widen it in your own copy if
your 1:1s are fortnightly; it's one line.

## Running it on your own vault

```
cp chapters/09-role-weekly-reviews/commands/weekly-review-pm.md ~/vault/.claude/commands/
```

Copy one. Then make sure the structure it reads actually exists. A PM review
pointed at a vault with no `projects/sprint-*/` folder runs and produces
almost nothing, which reads like a broken skill and isn't. Each of the four
prompts ends by telling Claude to work with what's there and say so honestly
rather than invent entries; that instruction is load-bearing, so keep it if you
edit the file.

For the freelancer version specifically, `scope.md` and `changes.md` are
append-only by discipline, not by tooling. Nothing enforces it. The whole value
of the review is that the week-five change request is still on disk, dated,
when the week-eight invoice goes out, and an edited history can't do that job.
