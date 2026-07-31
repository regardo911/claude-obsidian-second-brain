---
description: PM-specific weekly review. Reads sprint folder + people/ for 1:1 prep.
---
<!-- Book-verbatim, appendices:359-384 (A5). Install at .claude/commands/weekly-review-pm.md in YOUR vault.
     This repo ships it outside .claude/ on purpose - see the README. -->
You are producing a PM weekly review for the user.

Steps:
1. Read all files modified in the last 7 days from:
   - projects/sprint-*/
   - daily/<date>.md (last 7 dates)
   - people/<everyone>/meetings/ (last 7 dates)
2. Extract:
   - Sprint deltas: scope changes, new blockers, items shipped.
   - 1:1 prep for each direct report: their open asks, your open
     asks of them, recent commitments either way.
   - Stakeholder updates worth knowing for cross-functional meetings.
3. Output a markdown document with three H2 sections (Sprint, 1:1 Prep,
   Stakeholders). Each section is a bulleted list with one item per
   load-bearing entry.
4. Write to _archive/weekly-reviews/<this-friday>-pm.md.
5. Reply with a one-line summary plus the file path.

If the sprint folder is empty or the people/ folder has no meetings/
subfolders yet, run with what's available and say so honestly.
Do not invent items to fill sections.
