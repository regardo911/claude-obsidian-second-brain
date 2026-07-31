# Chapter 5: CLAUDE.md

Two files here. [`CLAUDE.template.md`](CLAUDE.template.md) is the Appendix A1
template, the one you fill in. [`worked-example-freelancer.md`](worked-example-freelancer.md)
is the completed one from ch05:55-116, kept so you can see what "filled in"
means before you try it.

## What you build

One file at the root of your vault, seven sections, in this order:

Identity · Folder Schema · Active Projects · Decision Log Pointer ·
People & Entities · Session-Closer Rules · Anti-Patterns

The order is load-bearing and the book is emphatic about it (ch05:181). Lead
with Anti-Patterns and you get a model that hedges on everything; lead with
Identity and you get one that is trying to help and avoiding three named
pitfalls.

## The one command

The command is `wc -l`, and it is the whole quality gate:

```
$ wc -l chapters/05-claude-md/worked-example-freelancer.md
      60 chapters/05-claude-md/worked-example-freelancer.md
```

Sixty, on the file the book prints. The target band for *your* filled-in
version is 80 to 150 lines (ch05:23), and the worked example is under it
because it's one freelancer with five one-line projects and no `people/`
entries yet. Take the shape from it, not the length.

Two numbers worth keeping straight: the Anthropic docs say keep CLAUDE.md
under 200 lines because "longer files consume more context and reduce
adherence" (ch05:11). 80 to 150 is the book's tighter house rule inside that.

## What success looks like

Fresh session, no preamble, in your vault:

> what folder do I drop a meeting note into?

Claude answers `daily/` or quotes the schema back. If it asks you what kind of
meeting note, Folder Schema is too vague. Second test, from ch05:147:

> what active project should I work on first today, and where do I find its decisions log?

It should name a project from your Active Projects section and point at that
project's `decisions.md`. Asking for clarification means Active Projects needs
real paths, not categories.

## Running it on your own vault

```
cp chapters/05-claude-md/CLAUDE.template.md ~/vault/CLAUDE.md
$EDITOR ~/vault/CLAUDE.md
wc -l ~/vault/CLAUDE.md
```

Replace every bracketed block with your own truth. Identity gets five lines
maximum. Active Projects is the section that goes stale; expect to edit it
weekly and the other six roughly quarterly.

## One deviation from the printed template

The template's Anti-Patterns section carries an added HTML comment, and it is
the only thing in either file that is not verbatim from the book.

The book's Anti-Patterns say `Do not write into _archive/ directly`
(appendices:58, ch05:109). But `/weekly-review` writes to
`_archive/weekly-reviews/` (ch07:211), all four role reviews do the same
(ch09:49, ch09:86, ch09:125, ch09:159), `cross-linker` writes
`_archive/cross-link-suggestions.md` (ch08:152), and the Chapter 11
diagnostic writes `_archive/diagnostics/<today>.md` (ch11:91). Five of the
book's own artifacts break its own rule.

The rule is right and the artifacts are right; what's missing is the carve-out.
An HTML comment carries it, so the printed lines stay untouched, Obsidian
renders nothing extra, and Claude still reads it. The wording, if you'd rather
paste it in as a visible bullet:

```
- Do not write into _archive/ directly. Archive is for moved files.
  Generated review, diagnostic and cross-link output is the exception:
  the skills and subagents write those under _archive/ by design.
```

That is the version `sample-vault/CLAUDE.md` uses.
