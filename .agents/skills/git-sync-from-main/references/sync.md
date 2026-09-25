# Git sync edge cases

## Fetch and fast-forward main

Run only in the primary checkout, never inside `worktrees/` (a worktree on
`main` locks the branch so `git checkout main` fails here).

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
```

- `git checkout main` fails with `already used by worktree`: do not check out
  `main` in that worktree. Run the linear-worktrees sweep, remove the leftover
  if it is Done/Canceled or has no unique work, then retry here.
- Already in `worktrees/<issue-id>`: skip `git checkout main`; fetch and rebase
  the issue branch onto `origin/main` instead.
- `--ff-only` fails: stop. Do not rebase or merge `main` yourself.

## Create or check out the branch

Branch does not exist locally or on origin:

```bash
git checkout -b "$BRANCH" origin/main
```

Branch exists only on origin:

```bash
git checkout --track "origin/$BRANCH"
git rebase origin/main
```

Branch exists locally:

```bash
git checkout "$BRANCH"
```

Then:

- No unique commits vs `origin/main`: `git reset --hard origin/main`.
- Unique commits: `git rebase origin/main`.
- Rebase conflicts: stop and tell the user. Do not `--skip` or force through.

## Dirty tree without an issue id

If `git status --porcelain` is non-empty, there is no issue id, and the user has
not asked for a worktree: stop and tell the user. Do not stash, discard, or
commit unless they ask.

## Why the gate is separate

The start-of-task check is not enough. The observed failure was: merge the PR,
run `git checkout main && git pull`, then begin the next slice and commit on
`main`. Re-check in the same command that commits or pushes. The global hook in
git-guard is the backstop; the gate catches the stale branch first.
