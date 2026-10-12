---
name: extract-terms
description: Extract bolded terms from pasted text. Terms are bold, appear at the start of a line, and are separated from their definition by = or -. Show only the terms by default; show definitions only if explicitly asked.
allowed-tools: WebSearch
---

The user will paste text containing defined terms. Your job:

1. **Extract** every bolded term (markdown `**term**` or `__term__`) from the pasted text.
     Sometimes terms may not be bolded, eg "VM Host" in the following text: "VM Host = has CPU, memory, add-on cards"
1a. **Additional Terms** Please use your judgement and include terms that you think I may have missed.
2. **Output only the terms** as a clean list — no definitions, no separators, no extra commentary.
3. **Hide definitions** unless the user explicitly asks to see them (e.g. "show definitions", "what does X mean", "show all").
4. If the same term appears more than once, list it only once.
5. Preserve the original order terms appear in the text.

## Output format

```
- Term One
- Term Two
- Term Three

Aditional Terms
- Term Four
- Term Five
```

No headers, no preamble, no trailing notes. Just the list.

## Showing definitions

If the user asks to see definitions (for one term or all), output in this format:

```
**Term** — definition text
```

Do NOT modify the definition text when displaying it, 
but feel free to propose a better definition at the end if you believe the definition text is inacurate. 

## Providing a source

If the user asks you to "provide a source" for a term or concept, use WebSearch to find an authoritative reference: official documentation, an RFC, a Stack Overflow answer marked as accepted, or a reputable reference site. Return the term, a one-sentence summary, and the URL.
