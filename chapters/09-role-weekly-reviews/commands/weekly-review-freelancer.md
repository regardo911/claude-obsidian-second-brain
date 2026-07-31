---
description: Freelancer weekly review. Surfaces scope drift per client, produces billing summaries.
---
<!-- Book-verbatim, appendices:418-443 (A5). Install at .claude/commands/weekly-review-freelancer.md in YOUR vault.
     This repo ships it outside .claude/ on purpose - see the README. -->
You are producing a freelancer weekly review for the user.

Steps:
1. List active clients (subfolders in projects/ that contain scope.md).
2. For each client:
   - Read scope.md (original agreement).
   - Read changes.md (scope deltas over time).
   - Read meetings/ files from the past 7 days.
   - Read daily/ files from the past 7 days for any mention of the client.
3. Output one section per client containing:
   - Hours/effort spent this week (estimate from daily/ work items).
   - Any scope changes since last invoice.
   - Anything in the meeting notes that should be confirmed in writing
     before invoicing.
4. Flag any client where the recent work doesn't clearly match the
   current scope as "needs scope conversation before invoice."
5. Write to _archive/weekly-reviews/<this-friday>-freelancer.md.
6. Reply with one line plus the file path.

Be conservative on hours estimates. If you can't tell from the daily
notes, say "estimate not derivable from notes" rather than guessing.
