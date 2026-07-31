# claude-obsidian-second-brain

**Build the book's Claude Code + Obsidian system in your own vault: five folders, a CLAUDE.md
that sticks, five lifecycle hooks, five commands, three subagents, a role-specific weekly review,
and a diagnostic you can run every month.**

In plain English: this repo helps Claude Code remember your work by reading and writing
structured notes inside your Obsidian vault. You don't need to know what a hook or a subagent
is yet. Pick your line below and the chapter folders explain each piece as you get to it.

![Two panels side by side under the title "What changes when your AI has a vault". Left, WITHOUT A VAULT: a lone terminal surrounded by scattered greyed-out cards labelled Notion, Slack, Screenshots and Tab history, captioned "9:00 re-explain the project. 9:45 still no code." Right, WITH A VAULT: a terminal fed by CLAUDE.md and connected by arrows to five folders (_inbox, projects, daily, people, _archive), with an arrow running back from the folders into the terminal, captioned "9:00 the session already knows. 10:00 working patch."](docs/images/hero.png)

Companion to *Claude Code + Obsidian: The AI Second Brain Playbook*.
More at [youcanbuildthings.com](https://youcanbuildthings.com).

Every artifact the book has you create is in here as a real file, in the book's own names, one
folder per chapter. You copy them into your vault and they work as printed.

## Start here

Pick the line that describes you.

### "I don't have an Obsidian vault yet"

Start from nothing. This creates the five folders and drops the book's README into each one:

```
git clone https://github.com/regardo911/claude-obsidian-second-brain
cd claude-obsidian-second-brain
./chapters/04-build-the-vault/make-vault.sh ~/vault
```

Open `~/vault` in Obsidian and you'll see the five folders. Then go to
[Chapter 5](chapters/05-claude-md/) and write your CLAUDE.md, which is the file that makes the
vault a system rather than a folder. Work forward from there.

### "I already have a vault"

Find out what needs fixing before you change anything:

```
git clone https://github.com/regardo911/claude-obsidian-second-brain
cd claude-obsidian-second-brain
./chapters/11-diagnostic/vault-diagnostic.sh ~/your-vault
```

It reads your vault and prints a fix plan against the book's Chapter 11 thresholds. It only
counts and prints; it never edits the vault you hand it. Whatever it flags, the chapter that
fixes it is linked from the [chapter map](#chapter-map) below.

### "I finished the book and just want the files"

Go straight to [what goes where](#what-goes-where). Every artifact is ready to copy, exactly as
printed in the appendices.

## What goes where

The artifacts live under plain names in this repo, and they belong under `.claude/` in **your
vault**. Here is the whole mapping:

| Chapter | Copy this | To here, in your vault |
|---|---|---|
| 4 | `chapters/04-build-the-vault/folder-readmes/*` | one `README.md` in each of the five folders |
| 5 | `chapters/05-claude-md/CLAUDE.template.md` | `CLAUDE.md` at the vault root |
| 6 | `chapters/06-five-hooks/hooks/*` | `.claude/hooks/` |
| 6 | `chapters/06-five-hooks/settings.hooks.json` | merge into `.claude/settings.json` |
| 7 | `chapters/07-five-skills/commands/*` | `.claude/commands/` |
| 8 | `chapters/08-three-subagents/agents/*` | `.claude/agents/` |
| 9 | `chapters/09-role-weekly-reviews/commands/*` | `.claude/commands/` (pick the one role that fits you) |
| 11 | `chapters/11-diagnostic/link-check.sh` | `scripts/link-check.sh` |
| 12 | `chapters/12-thirty-day-plan/thirty-day-plan.template.md` | `projects/vault-30day/README.md` |

After you copy the hooks, make them executable. Use `chmod +x .claude/hooks/*` rather than
`*.sh`, because one of the five handlers is a Python file and the `.sh` glob skips it.

Each chapter README repeats its own destination and gives you the exact command.

## Chapter map

| Chapter | What you build | Command | Success looks like |
|---|---|---|---|
| [02](chapters/02-five-folder-schema/) | fifteen real notes sorted into five folders | none, it's a worksheet | your "doesn't fit" list is 3 items or fewer |
| [04](chapters/04-build-the-vault/) | the vault skeleton + 5 READMEs | `make-vault.sh ~/vault` | five folders in Obsidian's pane |
| [05](chapters/05-claude-md/) | CLAUDE.md, 7 sections | `wc -l CLAUDE.md` | a fresh session answers *what folder do I drop a meeting note into?* |
| [06](chapters/06-five-hooks/) | five lifecycle handlers | `run-hooks-offline.sh` | Claude names your active project before you do |
| [07](chapters/07-five-skills/) | `/capture` `/daily` `/plan` `/process-inbox` `/weekly-review` | `/capture <thought>` | a correctly-named file lands in `_inbox/` |
| [08](chapters/08-three-subagents/) | brag-spotter, slack-archaeologist, cross-linker | `claude agents` | all three list as project-scoped |
| [09](chapters/09-role-weekly-reviews/) | one role review of four | `/weekly-review-<role>` | it surfaces something you'd forgotten |
| [10](chapters/10-semantic-search/) | local embeddings (no files, by design) | `export OLLAMA_ORIGINS=... && ollama serve` | a concept query finds a note with no keyword match |
| [11](chapters/11-diagnostic/) | the 5-question diagnostic | `vault-diagnostic.sh ~/vault` | a fix plan naming your files |
| [12](chapters/12-thirty-day-plan/) | the 30-day plan, in the vault | copy it to `projects/vault-30day/` | Claude reads the plan back on the first prompt |

Chapters 1 and 3 get no folder. The book's build step for both is "none", and manufacturing one
would be inventing homework.

## What the diagnostic gives you

```
$ ./chapters/11-diagnostic/vault-diagnostic.sh ~/your-vault
```

Run against the sample vault that ships here:

```
| # | Question | Threshold | Measured | Verdict |
|---|---|---|---|---|
| 1 | Dead `[[wikilinks]]` | more than 5 | 6 | **CROSSED** |
| 2 | `_inbox/` items older than 7 days | more than 3 | 2 | under threshold |
| 3 | `projects/` subfolders untouched 30 days | more than 2 | 0 | under threshold |
| 4 | cross-linker missing-link suggestions | more than 10 | unknown | needs Claude Code |
| 5 | `CLAUDE.md` last touched | more than 90 days | 0 days ago | under threshold |

## Fix plan

- [ ] **Dead links.** 6 dead wikilinks, 1 dead relative link. Repair the targets...
- [ ] **Question 4 is yours to run.** In Claude Code, in this vault: *Run the
      cross-linker subagent.*
```

The output is markdown, so `> _archive/diagnostics/$(date +%F).md` keeps the plan where the book
puts it. Run it monthly, as Chapter 11 suggests.

Question 4 says `unknown` and always will. Counting cross-link suggestions means running the
`cross-linker` subagent, and a shell script can't do that. A number invented there would be worse
than no number.

## The five hooks

![Five boxes left to right: SessionStart reads CLAUDE.md, UserPromptSubmit reads the schema slice, PostToolUse writes daily/, PreCompact asks Claude to write decisions, Stop asks Claude to apply the closer. A dashed arrow curving back from Stop to PostToolUse labelled "Stop only fires if PostToolUse wrote something".](docs/images/hook-lifecycle.png)

The dashed arrow is the part that surprises people. `Stop` reads what `PostToolUse` wrote, so if
the logger isn't running the closer silently never fires (ch06:347). Ordering isn't cosmetic.

![Three columns. HOOKS: automatic, lifecycle-triggered, shared context. SKILLS: manually invoked, one-shot, parent context. SUBAGENTS: own context window, runs in parallel, fixed mandate. An arrow from hooks to skills labelled "typed it twice" and one from skills to subagents labelled "too big for one prompt".](docs/images/layer-ownership.png)

Which layer a new idea belongs in: typed it twice, make it a skill. Too big for one prompt, make
it a subagent. Should happen whether you remember or not, make it a hook.

## What you need to run this

`bash`, `jq` and Python 3.9 or newer. Nothing else. Both extras are ones the book already has you
install (ch06:102).

The tooling runs with no key, no account and no network. That covers `vault-diagnostic.sh`,
`link-check.sh`, `run-hooks-offline.sh`, `make-vault.sh`, the five handlers and `tests/run.sh`.

The nine commands and three subagents are the exception, and it's the honest kind. They're
markdown files Claude Code reads, so they need Claude Code and a model, which you already have if
you read the book. Nothing here tests what Claude does with them, and nothing here simulates one.
A test that pretended to run `/capture` would be testing a mock of Claude.

## Why this repo doesn't auto-install

The hooks, commands and subagents ship as `hooks/`, `commands/`, `agents/` and
`settings.hooks.json`, rather than as `.claude/hooks/`, `.claude/commands/`, `.claude/agents/`
and `.claude/settings.json`.

That's on purpose. If they shipped under `.claude/`, opening your clone in Claude Code would
attach all five hooks to the clone itself, including the `PostToolUse` handler that writes
`daily/<today>.md` the first time you edit a file. You'd get a vault log inside a repo you were
only reading.

The book makes the same point from the other direction: hooks are registered in the settings
file, not discovered in a folder, so the directory name is a convention rather than a
requirement (ch06:34). Copying them into `.claude/` in your own vault is what activates them,
and that's the step you take deliberately.

## Where the book and its own code disagree

Three of the printed artifacts don't do what their explanation says they do. Rather than quietly
correcting them, this repo ships the book's version and the repair side by side, and
`tests/run.sh` asserts the bug on the first and its absence on the second. So "fixed" is
something you can check rather than something you're told.

If you copied the scripts straight out of the book, two of them are worth knowing about:
`user-prompt-submit.sh` sends a blank active project on every prompt, and `stop.sh` fires the
session closer in exactly the case its guard exists to prevent. Both repairs are in
`chapters/06-five-hooks/hooks-fixed/`.

Full details, with the real error output, in [GOTCHAS.md](GOTCHAS.md).

## Privacy, precisely

From the book (ch11:53):

> vault files are local at rest; the contents Claude reads during a session are not local in
> flight.

Both halves matter. Your vault is plain markdown on your own disk and no process here sends it
anywhere. But when Claude reads a file during a session, that file's contents go to Anthropic's
API, because the model runs there. If some material must never touch an API, keep it in a
separate vault you don't open with Claude Code, and use Chapter 10's local Ollama setup for it.

## Testing

```
./tests/run.sh
```

114 assertions, no network, no keys. It feeds every fixture to every handler, checks the JSON
shape and exit codes, asserts all three book-bugs on the verbatim artifacts and their absence on
the repaired ones, and runs the diagnostic against a clone-fresh vault, an artificially aged one,
and three shapes it wasn't built around. It prints the assertion count and fails if that count is
ever zero.

It doesn't cover the five commands or the three subagents. Nothing offline can.

## License

MIT, see [LICENSE](LICENSE). Educational software, provided as-is, without warranty of any kind.
