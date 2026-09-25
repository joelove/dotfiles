---
name: review
description: >-
  Review code changes with a subagent, choosing between code review and
  security review. Use when the user invokes /skill:review or asks for a review
  and needs to pick a type.
disable-model-invocation: true
---

# Review

Ask the user which review to run with pi's `question` tool. Provide exactly one single-select question with two options:

- `code`: Code review (`/skill:review-code`)
- `security`: Security review (`/skill:review-security`)

After the user chooses, follow the matching skill once:

- Code review: follow `review-code`.
- Security review: follow `review-security`.
