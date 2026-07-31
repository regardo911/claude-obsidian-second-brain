<!-- CLAUDE.md - Appendix A1, the template. Save at the root of your vault.
     Replace every bracketed block with your own situation; target 80 to 150
     lines once filled in (ch05:23). Every printed line below is the book's.
     The one repo addition is the comment in Anti-Patterns, which is marked. -->

# Identity

[2-3 sentences. Your role, your primary tools, the rough scope of work.
Example: "I am a freelance backend developer working with three active
clients (referenced in Active Projects) plus a personal blog and an
ongoing exploration of AI tooling. I work in Python, TypeScript, and
SQL daily. I bill hourly and track time in Toggl."]

# Folder Schema

The vault has five top-level folders:
- _inbox/    — capture-first; processed weekly into other folders
- projects/  — one subfolder per active project (README + decisions.md + notes.md)
- daily/     — one file per day in ISO format (e.g., 2026-04-26.md)
- people/    — one subfolder per recurring contact
- _archive/  — dormant projects and processed daily notes

# Active Projects

[One line per active project. Format: "projects/<slug>/ — <one-line goal>".
Example:
- projects/acme-exports-api/ — backend client; export endpoint refactor
- projects/q3-roadmap-doc/   — quarterly planning, draft due May 15
- projects/blog-pipeline/    — weekly post on AI tooling]

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
<!-- Repo note, not in the book. Take this rule with one carve-out.
     /weekly-review (ch07:211), the four role reviews (ch09:49/86/125/159),
     cross-linker (ch08:152) and the Chapter 11 diagnostic (ch11:91) all write
     under _archive/. They are supposed to. Add this line if you want it said
     out loud rather than left implicit:
       Generated review, diagnostic and cross-link output is the exception:
       the skills and subagents write those under _archive/ by design. -->
- Do not generate placeholder text in people/<name>/profile.md.
  If real context is missing, write "TBD" rather than inventing.
- Do not run rm on files inside _archive/ even when asked to clean up.
