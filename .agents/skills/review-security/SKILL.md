---
name: review-security
description: >-
  Review code changes for security issues using the pi `security-reviewer`
  subagent. Use when the user asks for a security review or invokes
  /skill:review-security.
disable-model-invocation: true
---

# Review security

Use this skill when the user asks to run a security review (`/review-security`).

## Prerequisite

The subagent extension must be installed, with a `security-reviewer` agent defined in `~/.pi/agent/agents/security-reviewer.md` (see `create-subagent`). If the `subagent` tool is unavailable, say so and offer to review the diff inline instead.

## Launch

Launch exactly one `security-reviewer` subagent through the `subagent` tool:

- `agent: "security-reviewer"`
- `task:` a prompt with this exact shape:

```text
Full Repository Path: <absolute repository path>
Diff: <one of: "branch changes", "uncommitted changes">
Base Branch: <only include this line when reviewing branch changes against a known specific base branch>
Custom Instructions: <only include this line when the user gave specific review instructions>
```

The subagent computes the local diff from the repository path, so do not compute the diff yourself before launching it.

Default to `branch changes`, which reviews branch changes against the merge-base with the default/base branch, including committed, staged, and unstaged changes. If the user asks to review only uncommitted, local working tree, dirty, or not-yet-committed changes, use `uncommitted changes`.

In most cases do not provide `Base Branch`; the subagent infers the repository's default base. Provide it only when the current branch should be compared against a specific branch other than the default.

## Reviewing a specific PR or branch

If the user explicitly asks to review a specific PR or branch (`github.com/.../review`, `review <link>`, or `review <branch>`):

- Resolve the PR link, number, or branch name to the PR head branch or named branch.
- If it is already the checked-out branch, continue.
- If a different branch is checked out, try to switch to the target branch.
- If git refuses because local files would be overwritten or conflicts exist, explain the blocker and ask whether to stash local changes before retrying. Only stash after the user confirms.
- Launch the review subagent only after the target branch is checked out locally.

## If the subagent fails before producing findings

- Wrong invocation (missing `Full Repository Path`, missing `Diff`, wrong prompt shape, wrong agent): correct it and retry once immediately.
- Any other failure: retry once with the same prompt shape.
- If the same failure persists, stop. Briefly tell the user the review could not complete and include the short error or blocker. Do not keep retrying.

## Summarize

- Empty or missing diff: say so in one sentence.
- No issues: one line, for example "Security review found no issues".
- Issues: a compact markdown table sorted by severity (highest first) with exactly these columns: Severity, Location (file:line), Finding.

Do not fix findings or rerun review unless the user explicitly asks for that next step.
