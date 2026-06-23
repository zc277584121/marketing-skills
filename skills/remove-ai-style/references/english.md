# English AI-style reduction guide

Check the article for obvious AI-writing patterns, then make the smallest rewrite that removes the tell without flattening the author's voice. If a passage already sounds natural, leave it alone.

## Quick-scan scripts

Run these before reading line by line. The results are only jump points; still read the full text for rhythm, structure, and factual issues the scripts cannot catch.

Set the file path first:

```bash
file_path="<file_path>"
```

### Scan em dashes, en dashes, and thematic breaks

```bash
rg -n '[—–]|--|---|\*\*\*|___' "$file_path" || echo "No suspicious dashes or breaks found."
```

### Scan curly quotes and curly apostrophes

```bash
rg -n '[“”‘’]' "$file_path" || echo "No curly quotes or apostrophes found."
```

### Scan binary contrast patterns

```bash
rg -n -i "\\b(not only|not just|not merely|isn't just|doesn't just|more than just|rather than|instead of|not .{0,80} but|not .{0,80} also)\\b" "$file_path" || echo "No binary contrast patterns found."
```

### Scan AI-style openers and meta transitions

```bash
rg -n -i "\\b(in today's|ever-evolving|rapidly evolving|in the realm of|in the world of|delve into|dive into|unlock|harness|leverage|it is important to note|it is worth noting|this article (explores|examines|will)|this guide (explores|examines|will)|below is|here is|let's explore|let us explore)\\b" "$file_path" || echo "No obvious AI-style openers found."
```

### Scan generic prestige and filler words

```bash
rg -n -i "\\b(significant|crucial|pivotal|vital|robust|seamless|transformative|game-changing|cutting-edge|innovative|comprehensive|dynamic|nuanced|thoughtful|tapestry|landscape|journey|testament|underscores|highlights|plays a key role|plays a crucial role)\\b" "$file_path" || echo "No generic prestige words found."
```

### Scan copula-avoidance and marketing verbs

```bash
rg -n -i "\\b(serves as|stands as|acts as|represents a|marks a|boasts|features|offers a|holds the distinction|is designed to|is aimed at|refers to)\\b" "$file_path" || echo "No copula-avoidance patterns found."
```

### Scan canned closers and assistant residue

```bash
rg -n -i "\\b(in conclusion|to sum up|ultimately|moving forward|the future of|i hope this helps|let me know|would you like|as an ai|knowledge cutoff|based on available information|available sources|provided sources)\\b" "$file_path" || echo "No canned closers or assistant residue found."
```

### Scan over-structured lists and inline-bold headers

```bash
rg -n "^\\s*([0-9]+\\.|[-*])\\s+(\\*\\*[^*]+:\\*\\*|[A-Z][A-Za-z /-]{2,40}:)" "$file_path" || echo "No inline-header list patterns found."
```

### Scan placeholders and copy-paste residue

```bash
rg -n -i '\[(your name|insert|describe|link|source|todo|placeholder)[^\]]*\]|(INSERT_|PASTE_|TODO|TBD|202[0-9]-XX-XX)|```' "$file_path" || echo "No placeholders or fenced-code residue found."
```

> These scripts intentionally over-flag. Do not rewrite code blocks, quoted source text, citations, URLs, Markdown links, or brand names unless the surrounding prose clearly needs it.

---

## 1. Cut throat-clearing

Remove sentence openers that announce the writing instead of saying the thing.

> Bad: This article explores how teams can leverage vector databases in today's rapidly evolving AI landscape.
>
> Better: Teams use vector databases to keep retrieval fast as their AI apps grow.

Watch for: "It is important to note", "It is worth mentioning", "This guide will explore", "Below is", "Let's dive into", "In today's world".

## 2. Use normal punctuation

English can use em dashes naturally, but repeated em dashes are now a strong AI-writing tell. If a draft uses them more than once or twice, replace most with a period, comma, colon, parentheses, or a simpler sentence break. Avoid decorative horizontal rules before every section.

Curly quotes and apostrophes are not wrong in edited prose, but mixed straight and curly punctuation often means pasted model output. Normalize punctuation only when it fits the publication style.

## 3. Avoid binary contrast

AI prose often pretends to correct a misconception: "not just X, but Y", "not merely X", "rather than Y", "more than just". Usually the sentence can state the positive claim directly.

> Bad: Milvus is not just a vector database; it is a foundation for intelligent applications.
>
> Better: Milvus stores and searches vectors for AI applications that need low-latency retrieval.

## 4. Prefer plain verbs

Do not avoid "is", "are", or "has" just to sound polished. Replace inflated verbs with ordinary ones when they add no meaning.

Common swaps:
- "serves as" -> "is"
- "stands as" -> "is"
- "boasts" -> "has"
- "features" -> "has" or "includes"
- "plays a pivotal role in" -> the actual verb
- "underscores/highlights the importance of" -> the specific result

## 5. Replace generic importance with facts

Words like "significant", "crucial", "pivotal", "robust", "seamless", "transformative", "comprehensive", and "innovative" are often filler. Keep them only when the text proves them. Otherwise, replace the claim with a concrete detail.

> Bad: This robust solution plays a crucial role in modern data workflows.
>
> Better: The pipeline retries failed imports and records every skipped row.

## 6. Break listicle rhythm

AI drafts often move in neat threes: three adjectives, three clauses, three bullet sections, three closing takeaways. That rhythm becomes too smooth. Collapse weak triplets into one specific point, vary sentence length, and remove bullets that do not help scanning.

Do not force "human messiness" by adding slang or errors. The goal is less metronomic, not sloppy.

## 7. Put real actors in the sentence

Avoid passive voice, false agency, and vague authorities when the actor matters.

> Bad: A new benchmark was introduced to demonstrate that latency is reduced.
>
> Better: The team added a benchmark and cut p95 latency by 18%.

Watch for vague sources: "experts say", "researchers agree", "it is widely recognized", "available sources suggest". If the source is real, name it. If it is not verified, flag the claim instead of polishing it.

## 8. Use quieter headings and structure

Prefer sentence-case headings unless the publication style requires title case. Avoid rhetorical-question headings and generic sections such as "Challenges and Future Outlook", "Key Takeaways", or "Conclusion" when the section does not add new information.

Inline-bold list headers are useful in docs, but in essays and articles they often look machine-generated:

> Bad: - **Scalability:** The system can handle growing workloads.
>
> Better: The system can handle growing workloads without changing the ingestion code.

## 9. Remove assistant residue and placeholders

Delete knowledge-cutoff disclaimers, "based on the provided sources", "I hope this helps", "Would you like me to", and template leftovers such as `[insert source]`, `PASTE_URL_HERE`, or `2026-XX-XX`.

For citations, do not invent or smooth suspicious references. If a link, DOI, date, or quoted claim looks fabricated or incomplete, flag it for verification.

## 10. Preserve genre and voice

Technical docs, release notes, product pages, essays, and social posts need different levels of structure. Lists, bold labels, and title-case headings may be correct in docs or product UI copy. Keep deliberate stylistic choices when they fit the venue.

Do not over-humanize by adding contractions, jokes, slang, first-person anecdotes, or choppy fragments unless the surrounding voice already supports them. The safest rewrite is usually plainer, more specific, and less performative.
