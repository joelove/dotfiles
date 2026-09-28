---
name: github-prs
description: Open a GitHub pull request for review in the browser. Use after creating a PR, when asked to open one for review, or when starting a review of an existing PR.
---

# GitHub PRs: create and open for review

## Open a PR for review

Open the PR in the browser:

    gh pr view <ref> --web

`<ref>` is a PR number, URL, or `owner/repo#n`. From a checkout, `gh pr view
--web` uses the current branch's PR; from anywhere, name the PR. A project
wrapper can also be used, and any `owner/repo n` reference works:

    gh pr view OWNER/repo#123 --web
    gh pr view https://github.com/OWNER/repo/pull/123 --web

In the tmux dev-workspace, the gh-dash review pane opens PRs too: its stock `o`
opens the selected PR in the browser. (The old `o`-to-octo.nvim diff editing was
removed with Neovim.)

## After creating a PR

1. Create the PR (`gh pr create ...` or the GitHub MCP tools).
2. Open it for review: `gh pr view <the URL gh prints> --web`.
3. Continue with review-code or autopilot as appropriate.

## Notes

- croft's native `croft pr <n>` opens a PR review tab (files, checks, viewed
  marks) inside the running editor pane. It is an in-editor option a human can
  use; it is not wired into this browser flow.
