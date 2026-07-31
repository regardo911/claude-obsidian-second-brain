# Chapter 8: three subagents

`brag-spotter` · `slack-archaeologist` · `cross-linker`

Adapted in the book from breferrari/obsidian-mind (MIT). Three markdown files
in [`agents/`](agents/), each with frontmatter and a system prompt.

⛔ Shipped as `agents/`, not `.claude/agents/`. Install at
`.claude/agents/<name>.md` in **your** vault.

## Hooks, skills, subagents: which one is this?

![Three columns. HOOKS: automatic, lifecycle-triggered, shared context. SKILLS: manually invoked, one-shot, parent context. SUBAGENTS: own context window, runs in parallel, fixed mandate. An arrow from hooks to skills labelled "typed it twice"; an arrow from skills to subagents labelled "too big for one prompt".](../../docs/images/layer-ownership.png)

The line that matters at vault scale: a subagent gets its own context window.
With 2,000 notes the parent session cannot hold the slice you need, but a
subagent can scan everything under a fixed mandate and hand back a summary rather
than a transcript (ch08:15).

## What you build

| Subagent | Reads | Writes | Window |
|---|---|---|---|
| `brag-spotter` | `daily/` | `people/me/wins.md` | past 14 days |
| `slack-archaeologist` | a thread you paste | `people/<name>/profile.md` | the thread |
| `cross-linker` | `projects/ daily/ people/ _inbox/` | `_archive/cross-link-suggestions.md` | whole vault, skips `_archive/` |

Frontmatter: `name` and `description` are required, `tools`, `model` and
`skills` are optional (ch08:21, ch08:37-39). The `tools` allowlist is doing
real work here. `cross-linker` gets Write but its prompt forbids it from
touching source files, and `brag-spotter` writes to exactly one path.

## The one command, and why it isn't in this repo

```
Run the cross-linker subagent.
```

Typed to the parent session, in your vault. There is no shell equivalent and
this repo does not simulate one. A subagent needs Claude Code and a model, so
nothing here tests what these three do, same rule as the skills in Chapter 7.

You can check the files are *registered* without running them:

```
claude agents
```

All three should list under project-scoped agents. If they don't, the session
started before the files existed: restart it, or run `/agents` to reload
(ch08:297).

## What success looks like

`cross-linker` finishes and `_archive/cross-link-suggestions.md` exists,
holding a table of source, target, the quoted line, and the suggested
replacement, and every proposal is one you can judge in a couple of seconds.
That last part is the quality bar. A cross-linker that proposes every noun is
useless because reviewing it costs more than the links are worth, which is why
the prompt tells it to skip ambiguous matches rather than guess (ch08:161-163).

`brag-spotter` writes `people/me/wins.md` with three H2 sections. On a vault
that's a week old it will find very little and say so; the prompt tells it not
to invent wins to fill space, and honest sparseness is the correct first
result.

This subagent also answers question 4 of the Chapter 11 diagnostic. The
diagnostic script prints `unknown` there and asks you for the number, because
counting cross-link suggestions requires running cross-linker, and a shell
script can't.

## Running them on your own vault

```
mkdir -p ~/vault/.claude/agents
cp chapters/08-three-subagents/agents/*.md ~/vault/.claude/agents/
```

Restart Claude Code. Then, from the parent session:

```
Run brag-spotter and cross-linker in parallel against the past 7 days.
```

Ask for parallel explicitly. Whether two subagents run concurrently is decided
at the Task-tool call, not in the frontmatter, so naming it is what gets it
(ch08:184).

`slack-archaeologist` needs input you can't fake usefully. Paste a real thread
into the session first, then invoke it. If a first name is ambiguous it will
stop and ask rather than pick, which is the behaviour you want the first time
two people in your vault are both called Jamie.
