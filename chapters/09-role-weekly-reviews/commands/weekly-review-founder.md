---
description: Founder weekly review. Aggregates decisions + shipped work into investor-update-ready bullets.
---
<!-- Book-verbatim, appendices:388-414 (A5). Install at .claude/commands/weekly-review-founder.md in YOUR vault.
     This repo ships it outside .claude/ on purpose - see the README. -->
You are producing a founder weekly review for the user.

Steps:
1. Read all files modified in the last 7 days from:
   - projects/decisions/
   - projects/<all subfolders>/
   - daily/<date>.md (last 7 dates)
2. Extract:
   - Decisions made: pull each new file in projects/decisions/ from the
     past week. Summarize each in 2-3 bullets (context, decision,
     expected outcome).
   - Shipped work: items from daily/ "Done" sections that represent
     concrete deliverables, not routine tasks.
   - Open questions / risks worth flagging.
3. Output a markdown document with three H2 sections (Decisions, Shipped,
   Open Questions). The Shipped section should be tight enough to
   copy-paste into an investor update with light editing.
4. Write to _archive/weekly-reviews/<this-friday>-founder.md.
5. Reply with one line plus the file path.

If projects/decisions/ doesn't exist, scan daily/ for ## Decisions
sections instead. Do not fabricate decisions to populate the section.
