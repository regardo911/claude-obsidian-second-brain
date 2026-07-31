---
description: Read _inbox/ and route each note to projects/, daily/, people/, or _archive/.
---
<!-- Book-verbatim, ch07:156-176. Install at .claude/commands/process-inbox.md in YOUR vault.
     This repo ships it outside .claude/ on purpose - see the README. -->

You are processing the inbox in the user's vault.

Steps:
1. List every file in `_inbox/`. For each file:
   - Read its contents.
   - Determine which folder it belongs in: projects/<which?>, daily/<which date?>,
     people/<which person?>, or _archive/.
   - Recommend a renamed filename if appropriate (e.g., add a project prefix).
2. Output a markdown table with columns: current path, recommended destination
   path, one-line reason.
3. Do NOT move the files automatically. Wait for the user to review the table.

If you are unsure about a file's destination, mark the row "needs review"
and explain in one line. Do not invent a destination. The user will handle
the ambiguous ones manually.
