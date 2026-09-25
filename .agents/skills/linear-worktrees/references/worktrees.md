# Linear worktrees: preview, sweep, remove, forbidden

## Preview on localhost

Compose bind-mounts the primary checkout. A worktree is invisible to Docker
until you remount it. Never write compose YAML by hand.

Each stack repo maps to one or more Compose services and a port; the mapping
lives in the local dev-workspace profiles.

`dev use` looks at every stack repo and remounts those with `worktrees/<id>`;
the rest stay on the primary checkout. If the primary HEAD is already on the
issue branch and there is no worktree, that repo stays on primary.

From the infra repo (`direnv` puts `bin/` on PATH), or via the helper:

```bash
dev use CAN-739
# or
"$SCRIPT" preview "$WORKSPACE" CAN-739
```

Accepts `CAN-739`, `can-739`, or `739`. Does not create worktrees.

| Command | Purpose |
|---|---|
| `dev use CAN-739` | Remount the impacted apps at `worktrees/can-739` |
| `dev use --fresh CAN-739` | Same, and drop those apps' `.next` volumes |
| `dev use --fresh-modules CAN-739` | Also drop `node_modules` volumes |
| `dev use --clear` | All apps back to the primary checkout |
| `dev use` | Print every default app: worktree vs primary |

`dev down` deletes `.generated/` (including the remount file). Run
`dev use <issue-id>` again after a full down if you still need the worktree. On
sweep or `cleanup-issue`, if that issue is the active remount, run
`dev use --clear` so hiring/admin do not keep serving a removed tree.

## Sweep on completion

Do not skip because the repo looks clean, and do not check out `main` in the
worktree as a substitute for removal.

1. `"$SCRIPT" cleanup-issue "$WORKSPACE" <issue-id>`
2. `"$SCRIPT" sweep-all "$WORKSPACE"`
3. For each leftover row, `get_issue` on that id.
4. If the issue is Done or Canceled:
   - `clean`, `helper-dirt`, or `on-main` with no unique dirt:
     `"$SCRIPT" remove <repo> <issue-id>`
   - `dirty`: stop and tell the user. Do not `--force`.
5. `"$SCRIPT" prune <repo>` for each repo you removed from.

If `git checkout main` fails with
`already used by worktree at '.../worktrees/<id>'`: do not check out `main` in
that worktree. Run this sweep, remove the leftover if its issue is Done/Canceled
or it has no unique work, then retry `git checkout main` in the **primary**
checkout.

Sweep flags: `clean`, `helper-dirt` (safe to remove), `dirty` (unique
uncommitted work), `on-main` (locks the default branch; remove or move off
`main`).

## Remove

Remove `worktrees/<issue-id>` when the issue is Done or Canceled, the PR is
merged, the user asks, or a worktree is on `main`/`master` (leftover, not
in-progress work).

Stop if the worktree has unique uncommitted work. Helper env symlinks pointing
at the primary checkout are not unique work; `remove` restores them
automatically. Do not `--force` unless the user asks, or you confirmed the
remaining dirty files already exist on `origin/main`. Never `rm -rf` a
registered worktree. Then `"$SCRIPT" prune <repo>`.

## Forbidden

- Workspace siblings: `~/Projects/<repo>-can-123`
- Topic slugs: `<product>-<topic>`
- Cursor's `~/.cursor/worktrees` for workspace issue work
- `git worktree add` anywhere except `<repo>/worktrees/<issue-id>`
- `git checkout main` or `git checkout master` inside `worktrees/`
- Adding a worktree whose branch is `main` or `master`
- Leaving a worktree after the issue is Done, Canceled, or the PR is merged

If you find an old sibling, confirm the issue is complete (Linear Done and/or PR
merged, no unique uncommitted work), then `git worktree remove` that path from
the primary repo. Use `--force` only under the same rules as above.
