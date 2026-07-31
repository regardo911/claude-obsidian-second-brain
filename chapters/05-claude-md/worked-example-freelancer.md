<!-- The filled-in CLAUDE.md from ch05:55-116, verbatim. A reference for what
     "filled in" looks like, not a file to copy into your vault. -->

# The worked example, as printed

```markdown
# Identity

I am a freelance backend developer working with three active clients
(referenced in Active Projects below) plus a personal blog and an
ongoing exploration of AI tooling. I work in Python, TypeScript,
and SQL daily. I bill hourly and track time in Toggl.

# Folder Schema

The vault has five top-level folders:
- _inbox/    — capture-first; processed weekly into other folders
- projects/  — one subfolder per active project, with README + decisions.md + notes.md
- daily/     — one file per day in ISO format, e.g., 2026-04-26.md
- people/    — one subfolder per recurring contact (clients, collaborators)
- _archive/  — dormant projects and processed daily notes

# Active Projects

- projects/acme-exports-api/        — backend client; rebuilding the export endpoint by Friday
- projects/zenith-mobile-handoff/   — backend client; documenting the API for their iOS team
- projects/forge-billing-rewrite/   — backend client; migrating from Stripe to a custom layer
- projects/blog-pipeline/           — personal; weekly post on AI tooling
- projects/ai-tooling-explore/      — personal learning; ongoing notes in projects/ai-tooling-explore/notes.md

# Decision Log Pointer

Every active project subfolder has a decisions.md file. When asked
"what did I decide about X," check projects/<project>/decisions.md
first; if not there, fall back to grepping the daily/ folder by date
range.

# People & Entities

The people/ folder has one subfolder per recurring contact. Inside each
is a profile.md (role, context, what they care about), a meetings/
folder of dated 1:1 notes, and an open-asks.md tracking outstanding
items in both directions. When asked to prep for a meeting with X,
read people/X/ first.

# Session-Closer Rules

At the end of any session that touches active project work:
- Append a one-paragraph summary to daily/<today>.md naming what
  was done and any decisions made.
- Write any open questions into _inbox/<today>-questions.md for
  tomorrow's processing.
- Update the relevant projects/<project>/decisions.md if a
  meaningful decision was made.

# Anti-Patterns

Default behaviors to avoid in this vault:
- Do not create new top-level folders. If a category seems missing,
  ask before adding.
- Do not write directly into _archive/. Archive is for moved files,
  not new ones.
- Do not generate placeholder text in people/<name>/profile.md.
  If real context is missing, write "TBD" rather than inventing.
- Do not run `rm` on files inside _archive/ even when asked to clean
  up; archive is preserved by default.
```
