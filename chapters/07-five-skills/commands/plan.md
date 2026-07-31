---
description: Review active projects and recommend a priority order for the week.
---
<!-- Book-verbatim, ch07:119-144. Install at .claude/commands/plan.md in YOUR vault.
     This repo ships it outside .claude/ on purpose - see the README. -->

You are reviewing the user's active projects in `projects/`.

Steps:
1. List every direct subfolder of `projects/`. For each subfolder:
   - Read its README.md (or the first 200 lines of any project notes).
   - Read its decisions.md if it exists.
   - Note the project name, its goal, and any deadlines mentioned.
2. Output a markdown list ordering the projects by priority. For each:
   - Project name (linked to its folder).
   - One-line description of what it is.
   - One-line reasoning for the priority placement.
3. After the list, write 2-3 sentences naming what the user should do first
   today. Be specific: name the project and the next concrete action.

Be opinionated about priority. Use available signals: explicit deadlines,
recency of activity in decisions.md, scope size, blockers mentioned.
If there are obvious conflicts (two projects with the same deadline,
both needing significant time), name them.

Output the list to stdout (no file write); the user reads it and acts.
