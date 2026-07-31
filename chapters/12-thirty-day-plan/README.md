# Chapter 12: the next 30 days

One file: [`thirty-day-plan.template.md`](thirty-day-plan.template.md).

## What you build

A plan that lives in the vault it is about. The book's BUILD STEP names the
path, `projects/vault-30day/README.md`, and never prints the file, so this
one is authored to that spec: four week deliverables, one chosen Week 4
extension path, and space to record where you actually stalled.

The plan being *in* the vault is the point rather than a filing convention.
It's the first thing the vault holds about itself, and it's the first real
answer when you open a session and ask what's next.

## The one command

```
mkdir -p ~/vault/projects/vault-30day
cp chapters/12-thirty-day-plan/thirty-day-plan.template.md \
   ~/vault/projects/vault-30day/README.md
```

Then, in a Claude Code session in the vault:

> What's the next action on my Week 1 plan?

Claude should answer from the file without you pasting anything, because
SessionStart loaded CLAUDE.md and the plan is a project README where CLAUDE.md
says project READMEs live. If it asks you what plan you mean, that's not a
problem with this file. It's SessionStart or the Active Projects section, and
Chapter 6 is where to look.

## What success looks like

Four week-deliverables filled in, one Week 4 path chosen **now** rather than
in three weeks, and four weekends actually blocked out in your calendar. The
book is blunt that picking the extension path up front is what stops Week 4
becoming the week you don't start.

## Running it on your own vault

Edit the template before you commit to it. The four-week shape assumes you
started on a Saturday and read the book the weekend before; if you're already
running hooks, Week 2 is done and everything slides.

One line in the template that earns its place: `## Where you actually stalled`.
Most people stall at one of three points: the install hour overruns, week two
feels like overhead before any payoff has landed, or the first role review
comes back thin. All three are normal, all three are documented in ch12:124-132,
and all three have the same recovery: open `_inbox/`, write one note, save it.
The friction of stalling is almost never about the tooling.
