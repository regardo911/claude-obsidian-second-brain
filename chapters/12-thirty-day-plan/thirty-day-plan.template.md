<!-- Chapter 12 BUILD STEP (ch12:134-151). The book specifies this file and
     never prints it, so this is authored to that spec: four week
     deliverables, one chosen Week 4 extension path, filled in by you.
     Save at projects/vault-30day/README.md in YOUR vault. -->

# 30-day plan

Started: <!-- YYYY-MM-DD -->
Week 4 path chosen: <!-- Plugin | MCP | More skills -->

Four weekends. Pick them now and put them in the calendar; the plan works
because the dates exist, not because the list does.

## Week 1 — vault + CLAUDE.md

Deliverable: a working vault and CLAUDE.md, used for one week, with at least
seven daily notes.

- [ ] Saturday: chapters 2 and 4. Five folders on disk, Claude Code reading them.
- [ ] Sunday: chapter 5. A fresh session answers *what folder do I drop a meeting note into?* with no preamble.
- [ ] Weekdays: use it. Add nothing.

Do not jump to hooks this weekend even if you have the time. A week of Claude
forgetting things is what makes Week 2 feel earned instead of optional.

If you only do one thing: open Claude Code from inside the vault every morning.

## Week 2 — hooks

Deliverable: five working hooks, and a daily note that PostToolUse is filling
in by itself.

- [ ] Saturday: chapter 6, all five hooks, including testing them.
- [ ] Sunday: run them against real work. Fix what does not fire.
- [ ] Weekdays: notice that you have stopped typing context paragraphs.

Three failures account for nearly all of it: `chmod +x` missed a handler, `jq`
is not installed, or a relative path in `settings.json` resolves differently
from your terminal.

If you only do one thing: get SessionStart right.

## Week 3 — skills, subagents, role review

Deliverable: five skills, three subagents and your role review, all running.
The first review surfaces three things you had forgotten.

- [ ] Saturday morning: chapter 7, five skills, test each.
- [ ] Saturday afternoon: chapter 8, three subagents. Run brag-spotter over the daily notes you now have.
- [ ] Sunday: chapter 9. Author your role review and run it.
- [ ] Friday 4pm: run the role review for real.

Already over 1,500 notes? Do Chapter 10's semantic search this week instead of
Week 4.

If you only do one thing: run cross-linker on Friday and apply three of its
suggestions.

## Week 4 — one extension

Deliverable: <!-- fill in from the path you chose -->

Pick one. Not three.

- [ ] **Plugin** — a Claudian plugin for your role. Two to four days. For developers who want to extend the editor itself.
- [ ] **MCP** — a vault-retrieval MCP server, the tier-three sketch. One to two days, and the most code of the three.
- [ ] **More skills** — five more skills for shapes of work you keep retyping. An evening each.

The book recommends the third for most readers, and it is the smallest one on
the list. Five skills fold into the daily flow more reliably than one
infrastructure project you finish and then rarely touch. Decision rule: *I keep
typing the same shape of prompt* → skills. *I want the AI to do something the
editor does not expose* → plugin. *I want Claude to query the vault mid-session*
→ MCP.

If you only do one thing: pick the one that matches your real work and ship it.

## After

- [ ] Diagnostic on the first weekend of each month: `vault-diagnostic.sh ~/vault`
- [ ] Schema review quarterly
- [ ] Stop tweaking the schema and let it settle

## Where you actually stalled

<!-- Fill this in as it happens, not at the end. The three common ones:
     the install hour overran; week two felt like overhead before any payoff;
     the first role review came back thin. All three are normal and all three
     have the same recovery - open _inbox/ and write one note. -->
