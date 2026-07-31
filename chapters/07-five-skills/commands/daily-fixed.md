---
description: Open or create today's daily/<date>.md file with template.
---
<!-- REPAIRED. daily.md next door is the book's, verbatim (ch07:82-107).
     Install this at .claude/commands/daily.md in YOUR vault if you want the
     repair; only one of the two can own the /daily name.

     The bug is a race with the PostToolUse hook. If Claude edits any vault
     file before you run /daily, post-tool-use.py creates daily/<today>.md
     containing only "# <date>" and "## Vault Activity" (ch06:231-232). The
     book's /daily then sees the file exists, replies "Daily note exists" and
     stops (ch07:91-92), so ## Intent, ## Done and ## Open never get written.
     /weekly-review later reads Done and Open sections that are not there
     (ch07:203-206). Fix: fill in what is missing instead of bailing. -->

You are creating or opening today's daily note in the user's vault.

Steps:
1. Compute today's date in ISO format (YYYY-MM-DD).
2. Read `daily/<today>.md` if it exists.
3. If it does not exist, create it with the full template below and reply
   "Daily note created: <full path>".
4. If it exists and already has an `## Intent` heading, change nothing. Reply
   "Daily note exists: <full path>" and stop.
5. If it exists but has no `## Intent` heading, the PostToolUse hook created
   it before you got here. Do NOT overwrite it and do NOT touch anything
   already under `## Vault Activity`. Append the missing template sections,
   then reply "Daily note completed: <full path>" so the difference is visible.

The template:

# <today's date in long form, e.g., "Sunday, April 26">

## Intent
- (one bullet — what's the priority for today)

## Done
- (filled in throughout the day; one line per shipped item)

## Open
- (filled in at end-of-day; questions or items rolling forward)

Keep `## Vault Activity` wherever it already sits in the file. It is the hook's
section, it is append-only, and `/weekly-review` and the Stop hook both read it.
