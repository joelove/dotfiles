---
name: git-guard
description: Stop commits and pushes on main or master. Use before any git commit or push, or to recover from work already committed on the default branch.
disable-model-invocation: true
---

# Git guard

Never commit or push directly on `main` (or `master`) in a workspace repo. A
global git hook enforces this; this skill is the gate and the recovery.

## The gate

Run in the same command as the commit or push:

```bash
branch=$(git rev-parse --abbrev-ref HEAD)
case "$branch" in main|master) echo "stop: on $branch, branch first"; exit 1;; esac
```

Branch first, in this order:

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
git checkout -b "$BRANCH" origin/main   # $BRANCH is Linear gitBranchName
```

If the primary checkout is dirty or on another branch, use linear-worktrees
instead of stashing.

## The hook

- `core.hooksPath = /Users/joelove/.config/git/hooks`.
- `pre-commit` refuses a commit when HEAD is `main` or `master`.
- `pre-push` refuses a push to `refs/heads/main` or `refs/heads/master`.
- `~/Projects/dotfiles` is exempt: it commits to `main` by design.
- `ALLOW_MAIN_COMMIT=1` and `ALLOW_MAIN_PUSH=1` exist. Do not use them unless
  the user explicitly asks for that action; say so out loud when you do.

If the hook blocks you, the branch is wrong. Do not override.

If work is already committed on `main`, or you need the no-force-push recovery
or hook verification, use [references/recovery.md](references/recovery.md).
