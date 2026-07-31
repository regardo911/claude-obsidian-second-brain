# Chapter 10: semantic search

This folder has no files in it. Chapter 10 ships no artifact: the whole build
step is installing two pieces of other people's software and setting one
environment variable. Writing a wrapper script for that would be inventing
something the book never taught, and you'd have to maintain it.

![Three stacked bars, widest at the bottom. TIER 1 grep, under 200 notes. TIER 2 local embeddings, 200 to 2,000 notes. TIER 3 dedicated MCP, 2,000+ notes. Captioned "Retrieval tiers stack. None replaces the one below it." and "Author-imposed heuristics, not conventions."](../../docs/images/retrieval-tiers.png)

## What you build

Tier two: local embeddings, via the obsidian-copilot plugin over an Ollama
model on your machine. Tier one, grep, is what you already have from
chapters 4 through 8, and it keeps working. The tiers stack; none of them
replaces the one below.

Those note counts are the author's heuristics, not Claude Code or Obsidian
conventions (ch10:19). Yours could be off by a factor of two either way
depending on how concentrated your topics are. The real signal is a query that
used to return three good hits now returning thirty marginal ones.

## The one command

```
export OLLAMA_ORIGINS="app://obsidian.md*"
ollama serve
```

Order matters and this is the step that eats the afternoon. Set the variable
*before* starting the server. Start `ollama serve` first and the variable has
no effect, the plugin cannot reach the local server, and nothing in the
Obsidian UI tells you why. Quit Ollama, set it, start again.

The rest, in order:

```
ollama pull nomic-embed-text          # start here
ollama pull mxbai-embed-large         # slower, better embeddings, if you need it
```

Then in Obsidian: Settings → Community plugins → Browse → "Copilot for
Obsidian" → Install → Enable. Then Settings → Copilot for Obsidian → Add
Custom Model, enter the model name, pick `ollama` as the provider, save.

One flag not to look for: `ollama pull --quantize` does not exist. Quantization
is a model tag, so you pull `<model>:q4_K_M` by name (ch10:68). Blog posts cite
the flag because the writer guessed.

## What success looks like

Run a concept query with no exact keyword match in your vault. The book's
example is *what did I decide about pricing last quarter* against decision logs
that never use that phrase. The right file comes back on similarity alone.

Then the control, which matters more than the first test: query something with
no match at all, like *banana ice cream recipe*. You want nothing back, or
marginal hits with low scores. A plugin that confidently returns your pricing
note for that query is not indexing, it is guessing, and you would have trusted
it.

Both are observations you make in the Copilot panel. Nothing in this repo can
make them for you, and the first index takes ten to twenty minutes to build
before either test means anything.

## Running it on your own vault

There is nothing to copy from this folder; that's the point of it being empty.

Two limits worth knowing before you install anything. Embeddings are good at
"find me notes about X" and bad at "find the line where I wrote Y"; for exact
phrases grep is still the right tool, and the Copilot panel exposes both
(ch10:136). And embeddings index contents, not relationships. If the question
is which two notes link to each other, that's the wikilink graph and the
`cross-linker` subagent from Chapter 8, not this.

Tier three, a custom MCP server for vault retrieval, is sketched in the book
and not built (ch10:86-96), so it isn't built here either. If you get there,
the transport to use is local stdio, because the vault is on your laptop and
running the retrieval server anywhere else adds a network hop to a local file
read.
