---
description: Drop a quick note into _inbox/ with today's date and a slug.
---
<!-- Book-verbatim, ch07:39-62. Install at .claude/commands/capture.md in YOUR vault.
     This repo ships it outside .claude/ on purpose - see the README. -->

You are creating a capture note in the user's vault. The user has given you
a one-line input via $ARGUMENTS.

Steps:
1. Generate a short kebab-case slug from the input (3-5 words, lowercase,
   hyphens, no punctuation).
2. Create a file at `_inbox/<today>-<slug>.md` where <today> is the current
   date in ISO format (YYYY-MM-DD).
3. The file body should contain:
   - An H1 heading with the original input.
   - A blank line.
   - The literal text "Captured: " followed by today's date in long form.
   - A blank line.
   - The original $ARGUMENTS text again, as a paragraph, for searchability.
4. After writing the file, reply with one line: "Captured: <full path>".

Do not embellish, summarize, or add commentary. The capture is meant to be
fast and low-friction.
