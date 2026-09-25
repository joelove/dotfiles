---
name: git-sync-from-main
description: Branch from the tip of main before any code change or pull request, on the Linear issue branch. Use when starting a task that changes code, opens a PR, or works a Linear issue.
---

# Git sync from main

Before writing code or opening a PR, put each affected repo on the Linear issue
branch taken from the tip of `main`. Never work on `main`; the git-guard hook
enforces it.

- Every code change is logged in Linear.
- The branch name is always the issue's automatic git branch (`gitBranchName`).
  Never invent, shorten, or "improve" it.
- Sync only the repos you will edit, not every checkout.
- Skip only for read-only questions where no file changes.

## Resolve the issue

1. Identify the issue (`CAN-123`); search with `list_issues` if unknown.
2. If none exists, create one first: read linear-project-tracking.
3. `get_issue` and copy `gitBranchName` exactly.
4. Mark it In Progress.

## Sync the repo

```sh
git status --porcelain
git rev-parse --abbrev-ref HEAD
```

Let `$HEAD` be the current branch and `$BRANCH` be `gitBranchName`.

- `$HEAD` is already `$BRANCH`: stay in this checkout.
- Tree dirty, or `$HEAD` is a different Linear branch: use a worktree and
  continue in `worktrees/<issue-id>`. Read linear-worktrees. Never write files
  with the shell there.
- Clean and on `main`:
  ```sh
  git fetch origin
  git checkout main
  git pull --ff-only origin main
  git checkout -b "$BRANCH" origin/main
  ```
- Prefer `master` if `origin/main` is missing.

Confirm before editing:

```sh
git rev-parse --abbrev-ref HEAD
git merge-base --is-ancestor origin/main HEAD && echo "based-on-main"
```

## Gate before every commit and push

Run this in the same command as the commit or push, so a stale branch after a
merge is caught:

```sh
branch=$(git rev-parse --abbrev-ref HEAD)
case "$branch" in main|master) echo "stop: on $branch, branch first"; exit 1;; esac
```

Then run `pnpm typecheck`, `pnpm lint`, and `pnpm test` (or the repo's scripts)
before finishing, and open a PR.

## Rules

- Do not invent a branch name; use `gitBranchName`.
- Do not start work on `main`; do not override the git-guard hook.
- Do not `git checkout main` inside `worktrees/`.
- Do not force-push. Do not push unless the user asks or a PR step requires it.
- Do not update git config.
- If branch, dirty-tree, rebase, or `already used by worktree` handling is
  unclear, use [references/sync.md](references/sync.md).
