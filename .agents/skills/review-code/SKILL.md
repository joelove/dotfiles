---
name: review-code
description: >-
  Review code changes for bugs, quality, and correctness using the pi
  `reviewer` subagent. Use when the user asks for a code review or invokes
  /skill:review-code.
disable-model-invocation: true
---

# Review code

Use this skill when the user asks to review code (`/review-code`, "review this", "review my branch").

## Prerequisite

The subagent extension must be installed, with a `reviewer` agent defined in `~/.pi/agent/agents/reviewer.md` (see `create-subagent`). If the `subagent` tool is unavailable, say so and offer to review the diff inline instead.

## Launch

Launch exactly one `reviewer` subagent through the `subagent` tool:

- `agent: "reviewer"`
- `task:` a prompt with this exact shape:

```text
Full Repository Path: <absolute repository path>
Diff: <one of: "branch changes", "uncommitted changes", "natural language">
Base Branch: <only include this line when reviewing branch changes against a known specific base branch>
Change Description: <required only when Diff is "natural language"; list each changed file and what changed in it>
Custom Instructions: <only include this line when the user gave specific review instructions>
```

The subagent computes the local diff from the repository path, so do not compute the diff yourself before launching it. The repository path should be the active workspace or repository root for the code the user wants reviewed.

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
- Could not compute the diff (empty diff, missing metadata): retry once with `Diff: natural language`, omitting `Base Branch` and providing a per-file `Change Description`:

  ```text
  src/auth/login.ts (modified):
  - rewrote validateSession (L40-58) to check token expiry before the DB lookup

  src/auth/legacy.ts (deleted)
  ```

- Any other failure: retry once with the same prompt shape.
- If the same failure persists, stop. Briefly tell the user the review could not complete and include the short error or blocker. Do not keep retrying.

## Summarize

- Empty or missing diff: say so in one sentence.
- No issues: one line, for example "Code review found no issues".
- Issues: a compact markdown table sorted by severity (highest first) with exactly these columns: Severity, Location (file:line), Finding.

Do not fix findings or rerun review unless the user explicitly asks for that next step.
