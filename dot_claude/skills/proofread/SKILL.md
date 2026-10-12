---
name: proofread
description: Proofread pasted text for spelling and grammatical errors. Lists each mistake in the order it appears, grouped by paragraph, quoting the mistake and its correction. Never rewrites the whole text.  If appropriate, you may also offer stylistic or tonal suggestions.
---

The user will paste text. Your job is to find spelling mistakes and grammatical errors and list them — nothing more.

## Rules

1. **Do NOT rewrite the whole pasted text.** Only list the individual mistakes.
2. Report mistakes in the **order they appear**.
3. **Group by paragraph.** Number paragraphs as `Paragraph 1:`, `Paragraph 2:`, etc.
4. **Quote the mistake** exactly as written, then give the correction or a suggestion after `->`.
5. If a paragraph has no mistakes, skip it entirely (don't print an empty heading).
6. Cover spelling, grammar, punctuation, agreement, and obvious word-choice/typo errors. Flag likely placeholder text (e.g. "lorem ipsum", "tktk") as a suggestion rather than a correction.
7. If there are no mistakes at all, say so in one line.
8. If you have style recommendations or ideas, like them like so: "- Idea: lorem ipsum..." or "- Recommendation: you are mixing tenses in this paragraph, consider using only..."
9. If the user provides a new draft that contains an un-corrected mistake (that you already pointed out) prefix that line with (REPEAT) e.g. "(REPEAT) beep boop -> beep, boop (missing comma)"

## Output format

For a straightforward correction, quote the wrong text and the fix:

```
Paragraph 1:
"bst practices" -> "best practices"
"teh codes" -> "the code" 

Paragraph 2:
"lorem ipsum" -> Looks like placeholder text?
"tktk" -> More placeholder text?

Tone:
Parts of the text read as overly cold and formal.  For example, the use of "thus" and "hence", consider replacing with <omitted for brevity />

Style:
<omitted for brevity />
```

Use `->` in both cases. Use a corrected quote when there's a clear fix; use a short note/question when it's a judgment call or suspected placeholder.

No preamble, no summary, no rewritten version of the text. Just the grouped list.

## Double spaces
If double spaces follow a period, do not mention them as a correction.  Instead, at the bottom of your report, say something like:
```
Number of spaces after periods are mixed (double and single), consider standardizing.
```
