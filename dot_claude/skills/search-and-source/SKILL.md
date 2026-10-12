---
name: search-and-source
description: Research a question with web search and back every major assertion with a quoted source. Use when the user wants a researched, cited answer, asks you to "search and source", "look this up with sources", "find sources", "back this up", or wants claims verified against authoritative references.
allowed-tools: WebSearch, WebFetch
---

The user wants a researched answer where the claims are backed by real, quoted sources — not your own recollection.

## Process

0. State your hypothesis before doing any web searches, if you have one.  Please keep in mind that your hypothesis may be wrong and you should be 100% willing to change your mind!
1. **Search the web.** Use `WebSearch` (and `WebFetch` to read the actual page) before answering. Do not answer major factual questions from memory — verify against live sources.
2. **Prefer authoritative sources**, in roughly this order: official documentation, primary sources (specs, RFCs, standards bodies, the org/person being discussed), peer-reviewed or well-established reference works, reputable publications. Avoid content farms, SEO spam, and unattributed AI-generated pages.
3. **Read before quoting.** Fetch the page and quote text that actually appears on it. Never invent, paraphrase-into-quotes, or guess at a quote. If you can't find a supporting quote, say so.
4. **Cross-check** anything surprising, contested, or high-stakes against a second independent source.

## Backing up assertions

Every **major assertion** must be immediately followed by a quoted source. Use this exact format:

> "Exact quoted text from the source" —[Source Name](https://url)

Example:

> "Bases allow you to filter by frontmatter" —[Obsidian Docs](http://obsidian.md/tktk)

Rules for citations:
- The quote must be **verbatim** from the page you fetched.
- The link text is the source's name (e.g. "Obsidian Docs", "MDN", "RFC 9110"), the URL is the direct page.
- One quote per major assertion. Minor/connective statements don't each need a citation, but nothing load-bearing should be uncited.
- If sources **disagree**, present both with their respective quotes and note the conflict.

## Output format

- Lead with the direct answer to the question.
- Follow each major claim with its blockquoted, cited source as shown above.
- Keep your own connective prose minimal — the sources do the work.
- End with a short **Sources** list of every URL used, deduplicated.

## When you can't source something

- If a claim can't be backed by a source you actually found, **flag it explicitly**: "I couldn't find a source for this — treat as unverified."
- Never fill a gap with a fabricated quote or a made-up URL. A missing citation is fine; a fake one is not.
