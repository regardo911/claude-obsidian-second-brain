# Chapter 2: the five-folder schema

`_inbox/` · `projects/` · `daily/` · `people/` · `_archive/`

## What you build

A decision about fifteen real notes you already own. That's it. Nothing gets
installed in this chapter and no folder gets created; Chapter 4 does that.
What you produce here is a filled-in [folder-mapping worksheet](folder-mapping-worksheet.md).

## The one command

There isn't one, and there shouldn't be. This is the only chapter in the repo
whose deliverable is a judgement call rather than a file, so it ships a
worksheet and no script. A tool that sorted your notes for you would be
answering the question the exercise exists to make you answer.

The two constants the rest of the repo enforces come from here:

| Rule | Value |
|---|---|
| An `_inbox/` item is drift after | 7 days |
| A `projects/` subfolder is dormant after | 2 weeks |

Both are wired into `chapters/11-diagnostic/vault-diagnostic.sh`, which is
where you find out whether you kept to them.

## What success looks like

Every one of your fifteen rows has exactly one folder name next to it, and the
"doesn't fit" list is three items or fewer. If it's longer, the schema isn't
wrong. The sample is telling you something, and the worksheet says what.

## Running it on your own vault

Copy `folder-mapping-worksheet.md` anywhere you like and fill it in. It is a
worksheet, not a vault file, so it does not need to live in the vault:

```
cp chapters/02-five-folder-schema/folder-mapping-worksheet.md ~/vault-migration.md
```

Then open your real pile: Apple Notes, Notion, a Downloads folder full of
`.md`. Take five recent, five middling, five old. Fifty notes is not a better
exercise than fifteen; it is the same exercise with more procrastination in it.
