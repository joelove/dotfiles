# Em-dash replacement patterns

Pick the fix by the job the dash was doing, then re-read the sentence:

| The dash was... | Replace with | Before to after |
|---|---|---|
| Introducing an explanation or definition | Colon | "not a raw copy - a workflow rebuilt with placeholders" becomes "not a raw copy: a workflow rebuilt with placeholders" |
| Joining two independent clauses | Period, split into two sentences | "re-authorisation - never inherited from someone else's consent" becomes "re-authorisation. It is never inherited from someone else's consent." |
| A parenthetical aside | Parentheses, or commas | "Smart Start - the hero - and Living Templates" becomes "Smart Start (the hero) and Living Templates" |
| Piling on supporting details after a claim | Short separate sentences instead of one dash-spliced run-on | "Chosen: Smart Start as hero, Living Templates as secondary - starter pack as fallback" becomes "Chosen: Smart Start as the hero, Living Templates as secondary. Starter pack stays a fallback." |
| Pure emphasis or dramatic pause | Rewrite; there is usually a shorter sentence underneath | |

## Also check

- Any string the dash lives in that gets duplicated elsewhere: hover/tooltip
  text, alt text, doc files that mirror the copy, speaker notes, commit
  messages.
- Text near the fix that assumed the old sentence shape still reads correctly
  once split.
- Unrelated punctuation is fine and should not be touched: en dashes for ranges,
  hyphens in compound words.

## Why this matters

This came out of a deck-editing pass where the user repeatedly asked for em
dashes removed in favour of plainer, conversational phrasing, then made it a
standing rule. Casual spoken-register copy almost never uses em dashes; treat a
dash as a sign the sentence needs a rewrite, not a find-and-replace.
