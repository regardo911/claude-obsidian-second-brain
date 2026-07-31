---
description: Read the last 7 days of daily/ files and produce a weekly summary.
---
<!-- Book-verbatim, ch07:190-213. Install at .claude/commands/weekly-review.md in YOUR vault.
     This repo ships it outside .claude/ on purpose - see the README. -->

You are producing a weekly summary from the user's daily notes.

Steps:
1. Compute the date range for the past 7 days (today and 6 days back).
2. List daily/<date>.md files in that range. Read each one.
3. Extract from across all files:
   - Decisions made: any line that names an architectural, scope, or
     direction-setting choice.
   - Work shipped: items from the "Done" sections that represent
     completed deliverables (not just routine task ticks).
   - Items still open: items from the "Open" sections that are still
     unresolved at end of week.
4. Output a markdown document with three H2 sections (Decisions, Work
   shipped, Open). Each section is a bulleted list with one item per
   significant entry. Skip noise (routine emails, brief meeting notes,
   anything that wasn't load-bearing).
5. Write the output to `_archive/weekly-reviews/<this-friday>.md`.
6. Reply with one line: "Weekly review written: <full path>".
