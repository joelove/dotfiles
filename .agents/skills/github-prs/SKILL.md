---
name: github-prs
description: >-
  Create GitHub pull requests and open them for review in the Company editor
  pane (tmux + Neovim + octo.nvim). Use after `gh pr create`, when asked to
  open a PR for review, or when starting a review of an existing PR. Triggers
  on: open PR, open pull request, PR review, review this PR, after creating a PR.
---

# GitHub PRs: create and open for review

## Open a PR for review in the editor pane

`company-workspace review <ref>` opens a PR in the editor pane's Neovim
(octo.nvim) and enters review mode. It accepts a full URL, `owner/repo#n`, or
`owner/repo n`:

    company-workspace review https://github.com/Company-Org/company-orchestrator/pull/123
    company-workspace review Company-Org/company-orchestrator#123
    company-workspace review Company-Org/company-orchestrator 123

If the editor pane is not running nvim, it falls back to opening the PR in the
browser. In review mode: `<localleader>ca` comment, `<localleader>sa`
suggestion, `:Octo review submit` to submit (Ctrl-a approve / Ctrl-r request
changes).

## After creating a PR

1. Create the PR (`gh pr create ...` or the GitHub MCP tools).
2. Open it for review: `company-workspace review <the URL gh prints>`.
3. Continue with review-code or autopilot as appropriate.

## Notes

- The helper finds the `company-prs` session's nvim pane via the tmux option
  `@company_review_pane`; it works from any pane or cwd.
- gh-dash's PR list has an `O` keybinding that calls the same helper.
- Related skills: review-code, autopilot, git-sync-from-main, linear-project-tracking.
