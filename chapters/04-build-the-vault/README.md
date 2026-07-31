# Chapter 4: build the vault

Five folders, a README in each, on a path you pick.

## What you build

The vault skeleton. `make-vault.sh` does Chapter 4 steps 3 and 4: the
`mkdir -p` and the five folder READMEs, which are byte-for-byte the ones
printed at ch04:95-130 and live in [`folder-readmes/`](folder-readmes/).

It stops short of Chapter 5 on purpose. No `CLAUDE.md` gets written here,
because a CLAUDE.md that describes my projects instead of yours is worse than
none. Claude would open every session confidently briefed on the wrong work.

## The one command

```
./chapters/04-build-the-vault/make-vault.sh /tmp/demo-vault
```

```
Vault created at /tmp/demo-vault

total 0
drwxr-xr-x  7 you  staff  224 ... .
drwxr-xr-x  3 you  staff   96 ... ..
drwxr-xr-x  3 you  staff   96 ... _archive
drwxr-xr-x  3 you  staff   96 ... _inbox
drwxr-xr-x  3 you  staff   96 ... daily
drwxr-xr-x  3 you  staff   96 ... people
drwxr-xr-x  3 you  staff   96 ... projects

Five folders, a README in each. That is Chapter 4 steps 3 and 4 done.
...
```

Point it at a directory that already has files in it and it refuses:

```
$ ./chapters/04-build-the-vault/make-vault.sh ~/vault
~/vault is not empty.
...
  make-vault.sh "/Users/you/vault" --yes
```

That guard is the whole reason the script exists rather than a copy-paste
block. It would otherwise happily overwrite five READMEs in a vault you have
been using for a year.

## What success looks like

```
ls -a /tmp/demo-vault && cat /tmp/demo-vault/daily/README.md
```

Five directories, and the `daily/` README opens `One file per day, named by
ISO date`. Then, from Obsidian: File → Open folder as vault → pick the path.
The five folders show up in the file pane, `_archive/` and `_inbox/` floated
to the top by the underscore.

## Running it on your own vault

New vault:

```
./chapters/04-build-the-vault/make-vault.sh ~/vault
cd ~/vault && claude
```

Then the smoke test from ch04:157. Ask Claude to write
`_inbox/test-vault-check.md` and watch it appear in Obsidian without a
refresh. If it doesn't appear, you almost certainly ran `claude` from
somewhere other than the vault root.

Vault you already have: don't run this against it. Create the five folders by
hand (`mkdir -p _inbox projects daily people _archive`), move what's already
there into `_archive/`, and copy the READMEs across one at a time from
`folder-readmes/`. The book's advice at ch04:87 is to treat existing material
as legacy and mass-archive it rather than sort it up front; the sorting is
Chapter 2's worksheet, done in batches later.
