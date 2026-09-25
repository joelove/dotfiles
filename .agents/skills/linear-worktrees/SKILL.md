---
name: linear-worktrees
description: Create, reuse, and remove git worktrees under worktrees/<issue-id> for parallel Linear work, and sweep them when an issue is done. Use when the primary checkout is dirty or on another branch, or when a worktree is requested or has outlived its issue.
---

# Linear worktrees

Keep extra checkouts inside the repo, named by Linear issue id. Never create a
sibling next to the repo (`<repo>-can-600`).

## Related skills

- git-sync-from-main decides when a worktree is required; this skill creates or
  reuses it. Never `git checkout main` inside `worktrees/`.
- linear-project-tracking supplies the issue id and `gitBranchName`.

## Layout

```text
<repo>/
  worktrees/
    can-600/     # checkout for CAN-600
```

- Path is always `<repo>/worktrees/<issue-id>`, lowercase id.
- Branch is Linear `gitBranchName` from `get_issue`. Never invent one.
- A worktree stays on its issue branch. Never check out `main` or `master` in a
  worktree; it locks the default branch for the primary checkout.
- Keep `worktrees/` out of git with a local exclude (`.git/info/exclude`), not a
  committed `.gitignore` change.
- Keep idle worktrees out of Cursor search with a local `.cursorindexingignore`.
  Never add `/worktrees/` to `.cursorignore`; that blocks editor Read/Write.

## When to add

Use a worktree only when the primary checkout cannot take the issue branch:

- `git status --porcelain` is non-empty and HEAD is not already `$BRANCH`, or
- HEAD is on a different Linear branch, or
- the user asked for a separate worktree.

If HEAD is already `$BRANCH`, stay in the primary checkout even if dirty.

## Edit in the worktree

Set `$WT` to the absolute worktree path and do all file work there.

- `read`, `write`, `edit`, `grep`, `find`: pass paths under `$WT`.
- `grep` and `find`: use `$WT` as the path so you do not hit the primary.
- Never write or patch files with the shell (`cat`, heredocs, `python -c`,
  `sed -i`).
- Do not edit the primary checkout while this issue's worktree is active.
- Do not `git checkout main` in `$WT`; fetch `origin/main` and rebase the issue
  branch onto it.

## Helper

Run from the primary repo checkout:

```bash
SCRIPT="$HOME/.agents/skills/linear-worktrees/scripts/worktree.sh"
WORKSPACE="$HOME/Projects"   # the directory that holds your workspace repos
```

| Command | Purpose |
|---|---|
| `"$SCRIPT" ensure <repo>` | Create `worktrees/`, local exclude, `.cursorindexingignore` |
| `"$SCRIPT" add <repo> <issue-id> <gitBranchName>` | Reuse or add `worktrees/<id>` on the issue branch |
| `"$SCRIPT" remove <repo> <issue-id>` | Remove if unique-clean |
| `"$SCRIPT" cleanup-issue <workspace> <issue-id>` | Remove from every repo in the workspace |
| `"$SCRIPT" sweep <repo>` / `sweep-all <workspace>` | TSV of extra worktrees and flags |
| `"$SCRIPT" list <repo>` / `prune <repo>` | `git worktree list` / drop stale metadata |

After `add`, install deps in that checkout; do not symlink `node_modules`.

## Sweep on completion

Required whenever an issue is Done or Canceled, or its PR is merged, in every
workspace repo. If a worktree is the active local remount, run `dev use --clear`
first. Full procedure, preview, remove, and forbidden paths:
[references/worktrees.md](references/worktrees.md).
