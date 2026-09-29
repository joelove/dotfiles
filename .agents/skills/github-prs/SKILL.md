---
name: github-prs
description: >-
  Create pull requests as drafts and open them in the browser, promoting or
  merging only when explicitly asked. Use after creating a PR, when asked to
  open a PR, or when starting a review of an existing PR.
---

# GitHub PRs: create, open, and promote

## Create a PR

Default every PR to a **draft**, then open it in the browser:

    gh pr create --draft --base <base> --head <branch> --title <title> --body <body>
    gh pr view <the URL gh prints> --web

Create a ready-for-review PR only when the user explicitly asks for review:

- "open a PR for review", "ready for review", or "mark it ready" promote it now.
- A plain "open a PR", "ship it", or the normal shipping flow stays a draft.

For an explicit review ask, drop `--draft`:

    gh pr create --base <base> --head <branch> --title <title> --body <body>

## Draft is the resting state

A draft PR is where shipping normally ends. Leave it there.

- Never mark a PR ready, enable auto-merge, or merge it on your own.
- Promote only on an explicit ask:

      gh pr ready <ref>

- Merge agentically only on an explicit ask. Promote first, then enable
  auto-merge so GitHub merges once required checks pass:

      gh pr ready <ref>
      gh pr merge <ref> --auto --squash

  Auto-merge is available on the Candela repos except `candela-qa`. Where the
  repo does not allow it, watch checks and then squash merge:

      gh pr checks <ref> --watch
      gh pr merge <ref> --squash

  If checks fail, report the failure instead of merging.
- Never use `--admin`, never force-push, and never enable auto-merge unprompted.

## Open in the browser

`<ref>` is a PR number, URL, or `owner/repo#n`. From a checkout, `gh pr view
--web` uses the current branch's PR; from anywhere, name the PR:

    gh pr view <ref> --web
    gh pr view OWNER/repo#123 --web
    gh pr view https://github.com/OWNER/repo/pull/123 --web

In the tmux dev-workspace, the gh-dash review pane opens PRs too: its stock `o`
opens the selected PR in the browser. (The old `o`-to-octo.nvim diff editing was
removed with Neovim.)

## After creating a PR

1. Create the PR as a draft (`gh pr create --draft ...` or the GitHub MCP tools).
2. Open it: `gh pr view <the URL gh prints> --web`.
3. Leave it draft. Continue with review-code or autopilot as appropriate, and
   promote or merge only when the user explicitly asks.

## Notes

- croft's native `croft pr <n>` opens a PR review tab (files, checks, viewed
  marks) inside the running editor pane. It is an in-editor option a human can
  use; it is not wired into this browser flow.
