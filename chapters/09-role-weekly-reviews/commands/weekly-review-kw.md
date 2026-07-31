---
description: Knowledge worker weekly review. Aggregates meeting notes and surfaces forgotten asks.
---
<!-- Book-verbatim, appendices:447-471 (A5). Install at .claude/commands/weekly-review-kw.md in YOUR vault.
     This repo ships it outside .claude/ on purpose - see the README. -->
You are producing a knowledge worker weekly review for the user.

Steps:
1. Read daily/<date>.md files from the past 7 days.
2. Read people/<all>/meetings/ files from the past 7 days.
3. Extract:
   - Meetings attended this week (with one-line summaries).
   - Decisions made or witnessed.
   - Asks made of you that you haven't acted on yet.
   - Asks you made of others that you haven't followed up on.
   - Anything you flagged as "look at this later" that you haven't.
4. Output a markdown document with four H2 sections (Meetings, Decisions,
   My Open Asks, Their Open Asks). Tight bullets.
5. Write to _archive/weekly-reviews/<this-friday>-kw.md.
6. Reply with one line plus the file path.

The "Their Open Asks" section is load-bearing. It is the section that
catches a request from Tuesday's 1:1 that the user forgot about by Friday.
Be generous about what counts as an open ask; better to flag and dismiss
than to miss something.
