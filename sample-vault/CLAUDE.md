# Identity

I am a freelance backend developer with two active clients plus a personal
blog. I work in Python and SQL daily. I bill hourly and reconcile invoices
against the change log in each client folder, not against memory.

# Folder Schema

The vault has five top-level folders:
- _inbox/    capture-first; processed weekly into other folders
- projects/  one subfolder per active project (README + decisions.md + notes.md)
- daily/     one file per day in ISO format (e.g., 2026-04-26.md)
- people/    one subfolder per recurring contact
- _archive/  dormant projects and processed daily notes

# Active Projects

- projects/exports-api/    backend client; the export endpoint throws 500s on wide date ranges
- projects/legacy-import/  backend client; one-off CSV importer, paused pending their schema freeze

# Decision Log Pointer

Every active project subfolder has a decisions.md file. When asked
"what did I decide about X," check projects/<project>/decisions.md
first; if not there, fall back to grepping daily/ by date range.

# People & Entities

The people/ folder has one subfolder per recurring contact. Inside each:
profile.md, meetings/ folder, open-asks.md. When asked to prep for a
meeting with X, read people/X/ first.

# Session-Closer Rules

At session end, if active project work happened:
- Append a one-paragraph summary to daily/<today>.md.
- Write any open questions into _inbox/<today>-questions.md.
- Update the relevant projects/<project>/decisions.md if a decision was made.

# Anti-Patterns

Default behaviors to avoid:
- Do not create new top-level folders. Ask first.
- Do not write into _archive/ directly. Archive is for moved files.
  Generated review, diagnostic and cross-link output is the exception:
  the skills and subagents write those under _archive/ by design.
- Do not generate placeholder text in people/<name>/profile.md.
  If real context is missing, write "TBD" rather than inventing.
- Do not run rm on files inside _archive/ even when asked to clean up.
