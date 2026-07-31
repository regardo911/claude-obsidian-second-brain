# Chapter 6: the five hooks

The densest chapter in the book, and the one that turns CLAUDE.md from a
suggestion into something that fires. Read the picture first:

![Five rounded boxes left to right, connected by arrows: SessionStart reads CLAUDE.md, UserPromptSubmit reads the schema slice, PostToolUse writes daily/, PreCompact asks Claude to write decisions, Stop asks Claude to apply the closer. A dashed arrow curves backwards from Stop to PostToolUse, labelled "Stop only fires if PostToolUse wrote something". The left edge is captioned "reads the vault", the right edge "writes the vault".](../../docs/images/hook-lifecycle.png)

## Where these files go. Read this before you copy anything

⛔ **Nothing in this folder is installed by cloning.** The handlers are shipped
as `hooks/`, and the settings as `settings.hooks.json`, deliberately **not** as
`.claude/hooks/` and `.claude/settings.json`.

If they were, opening your clone in Claude Code would attach five hooks to it,
including a PostToolUse handler that silently writes `daily/<today>.md` inside
the clone the first time you edit a file. You cloned a companion repo; you did
not ask it to start logging.

The book agrees, as it happens: *"The directory `.claude/hooks/` is convention…
hooks live in settings, not in a folder"* (ch06:13, ch06:34). Where they live
is up to you; what binds them is the settings file.

Install destinations in **your** vault:

| In this repo | In your vault |
|---|---|
| `settings.hooks.json` | `.claude/settings.json` (merge the `hooks` key if you have one) |
| `hooks/session-start.sh` | `.claude/hooks/session-start.sh` |
| `hooks/user-prompt-submit.sh` | `.claude/hooks/user-prompt-submit.sh` |
| `hooks/post-tool-use.py` | `.claude/hooks/post-tool-use.py` |
| `hooks/pre-compact.sh` | `.claude/hooks/pre-compact.sh` |
| `hooks/stop.sh` | `.claude/hooks/stop.sh` |

`hooks/` is the book's code, byte for byte under the repo comment block at the
top of each file. `hooks-fixed/` holds two repairs, described below. Every
other file cites its source in its own header; `settings.hooks.json` can't,
because JSON has no comments; it is Appendix A2, lines 70-113.

## What you build

Five handlers, roughly a hundred lines of shell and Python between them
(ch06:352), wired to five lifecycle events in one settings file.

## The one command

```
./chapters/06-five-hooks/run-hooks-offline.sh
```

It copies `sample-vault/` to a temp directory, feeds each fixture to each
handler, and prints what comes out. No Claude Code, no network, no key. Real
output from a real run:

```
2. UserPromptSubmit -> re-injects the schema slice
==================================================
--- book version (hooks/) ---
- Active project:
--- repaired version (hooks-fixed/) ---
- Active project: exports-api

3. PostToolUse -> appends a line to daily/2026-07-31.md
=======================================================
  fed post-tool-use-file-path.json -> - 10:41 Write: `projects/exports-api/decisions.md`
  fed post-tool-use-path.json      -> - 10:41 Edit: `projects/exports-api/notes.md`
  fed post-tool-use-no-path.json   -> - 10:41 Edit: `?`

5. Stop -> only fires when PostToolUse actually logged something
================================================================

  daily note state: daily-no-activity    (correct behaviour: stay silent)
    book version:     injected the closer   <- stop.sh: line 13: [[: 0 0: syntax error in expression (error token is "0
    repaired version: silent
```

Pass your own vault as an argument and it copies that instead:
`./run-hooks-offline.sh ~/vault`. It always works on a copy, because
PostToolUse genuinely writes a file and you did not ask for one.

## The two repairs

Both were found by running the book's code, not by reading it. `tests/run.sh`
asserts the bug on the verbatim handler and its absence on the repaired one,
which is what makes the word "fixed" checkable.

**`user-prompt-submit.sh` never matches the book's own CLAUDE.md.** The awk
looks for `^## Active Projects` and backticked `` - `projects/ `` (ch06:173-176).
Appendix A1 and the ch05 worked example both write `# Active Projects` with one
hash and bare paths (appendices:27, ch05:72). So awk matches nothing, exits 0,
which means the `|| echo "none"` fallback never fires either, and every prompt
of every session carries `- Active project: ` with nothing after it. The hook
runs, reports success, and injects a blank.

**`stop.sh` throws an arithmetic error and does the opposite of its prose.**
`grep -c` prints `0` *and* exits 1 when it matches nothing, so `|| echo 0` fires
as well and `ACTIVITY` becomes the two-line string `0\n0`. Under bash you get
`[[: 0\n0: syntax error`, the guard reads false, and the closer directive gets
injected on a session that touched nothing. Under zsh the hook dies outright,
exit 1. ch06:343 says the check is what stops Stop being "a noisy
after-every-turn trigger"; it is the check that is broken.

The other three handlers ship unrepaired because they have nothing wrong with
them, so `hooks-fixed/` holds two files rather than five.

## What success looks like

Two checks, in this order. First, offline, before Claude Code is involved:

```
$ echo '{"session_id":"t","cwd":"'"$PWD"'","hook_event_name":"SessionStart","source":"startup"}' \
    | .claude/hooks/session-start.sh
```

A JSON object with `hookSpecificOutput.additionalContext` populated. An error
means the script is broken; nothing at all usually means `jq` isn't installed.

Then the real one, from ch06:372, which no test in this repo can stand in for.
Fresh session in your vault, no preamble:

> What's the next action on my active project?

Claude names the project from your `## Active Projects` before you mention it.
Then ask it to write `_inbox/hook-test.md`, and open `daily/<today>.md`: there
is a `## Vault Activity` line with a timestamp. That is the checkpoint, and it
is an observation you have to make yourself.

## Running it on your own vault

```
mkdir -p ~/vault/.claude/hooks
cp chapters/06-five-hooks/hooks/*        ~/vault/.claude/hooks/
cp chapters/06-five-hooks/settings.hooks.json ~/vault/.claude/settings.json
chmod +x ~/vault/.claude/hooks/*
```

Want the repairs? Copy `hooks-fixed/` over the top afterwards:

```
cp chapters/06-five-hooks/hooks-fixed/* ~/vault/.claude/hooks/
```

Note the `chmod` line. The book's recovery card says
`chmod +x .claude/hooks/*.sh` (ch12:120, appendices:627), and that glob leaves
`post-tool-use.py` non-executable, which is the one handler that isn't a `.sh`.
The BUILD STEP at ch06:366 lists all five by name and is right. Drop the `.sh`
and the problem goes away.

If you already have a `.claude/settings.json`, don't overwrite it. Merge the
`hooks` key in by hand. Then quit Claude Code and start a fresh session, or the
new settings aren't read.
