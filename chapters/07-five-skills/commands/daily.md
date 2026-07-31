---
description: Open or create today's daily/<date>.md file with template.
---
<!-- Book-verbatim, ch07:82-107. Install at .claude/commands/daily.md in YOUR vault.
     This repo ships it outside .claude/ on purpose - see the README. -->

You are creating or opening today's daily note in the user's vault.

Steps:
1. Compute today's date in ISO format (YYYY-MM-DD).
2. Check if `daily/<today>.md` already exists. If yes, reply with one line:
   "Daily note exists: <full path>" and stop.
3. If the file does not exist, create it with this template:

# <today's date in long form, e.g., "Sunday, April 26">

## Intent
- (one bullet — what's the priority for today)

## Done
- (filled in throughout the day; one line per shipped item)

## Open
- (filled in at end-of-day; questions or items rolling forward)

4. Reply with one line: "Daily note created: <full path>".
