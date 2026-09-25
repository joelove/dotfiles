---
name: github-prs
description: Open a GitHub pull request for review in the workspace editor pane (tmux + Neovim + octo.nvim). Use after creating a PR, when asked to open one for review, or when starting a review of an existing PR.
---

# GitHub PRs: create and open for review

## Open a PR for review in the editor pane

`dev-workspace [<profile>] review <ref>` opens a PR in the workspace's editor
pane (octo.nvim) and enters review mode. It accepts a full URL, `owner/repo#n`,
or `owner/repo n`:

    dev-workspace review https://github.com/OWNER/repo/pull/123
    dev-workspace review OWNER/repo#123
    dev-workspace review OWNER/repo 123

A project wrapper is a one-line `exec dev-workspace <profile> "$@"`, so
`<project>-workspace review <ref>` does the same for that project. If the editor
pane is not running nvim, it falls back to opening the PR in the browser. In
review mode: `<localleader>ca` comment, `<localleader>sa` suggestion,
`:Octo review submit` to submit (Ctrl-a approve / Ctrl-r request changes).

## After creating a PR

1. Create the PR (`gh pr create ...` or the GitHub MCP tools).
2. Open it for review: `dev-workspace [<profile>] review <the URL gh prints>`.
3. Continue with review-code or autopilot as appropriate.

## Notes

- The helper finds the profile's nvim pane via the tmux option
  `@dev_review_pane <profile>`.
- gh-dash's PR list has an `o` keybinding that calls the same helper (it
  replaces the built-in open-in-GitHub, and still falls back to the browser
  when the editor pane is unavailable).
