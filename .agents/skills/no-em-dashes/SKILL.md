---
name: no-em-dashes
description: Rewrite prose without em dashes (U+2014) or double-hyphen dashes when drafting or editing anything a person reads. Use for docs, UI text, commit messages, slides, and marketing copy.
disable-model-invocation: true
---

# No em dashes in copy

Never write an em dash (U+2014) or a double hyphen used as a dash in copy a
person reads. It reads as an AI tell and usually hides a sentence that should be
split. Replace each hit with the punctuation that fits: colon, semicolon,
comma, parentheses, or a second sentence. Do not just swap the character in
place, re-read the sentence and often split it.

Scan every user-facing string before finishing: docs, UI/hover/alt text, commit
messages, slides, marketing, speaker notes. En dashes for ranges (`9am` to
`5pm`) and hyphens in compound words (`chat-first`) are fine.

Replacement patterns and worked examples: [references/patterns.md](references/patterns.md).
