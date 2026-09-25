# Git guard recovery

## If the hook blocks you

1. No commits yet on `main`: `git checkout -b "$BRANCH" origin/main`, then
   commit.
2. Work is uncommitted on `main`: branching off `main` keeps the working tree,
   so `git checkout -b "$BRANCH" origin/main` and commit there.
3. Work is already committed on `main` and pushed: use the recovery below.

## Recovery: already committed to main (no force-push)

Never `git push --force` `main`. Branch the commit, revert `main`, then bring
the work back on the branch and merge it by PR:

```bash
git branch "$BRANCH" HEAD            # 1. keep the commit on a real branch
git push -u origin "$BRANCH"         # 2. publish the branch
git revert --no-edit <bad-commit>    # 3. undo it on main
git push origin main                 # 4. push the revert (needs ALLOW_MAIN_PUSH=1)
git checkout "$BRANCH"
git reset --hard origin/main         # 5. branch now matches reverted main
git revert --no-edit <revert-commit> # 6. re-apply the work as a new commit
git push                             # 7. PR from the branch
gh pr create --base main --head "$BRANCH"
gh pr merge <n> --squash --delete-branch
```

Step 4 is the one legitimate use of `ALLOW_MAIN_PUSH=1`, and only as part of
this recovery. If the recovery leaves a revert/reapply pair in history, that is
expected and benign; say so when reporting.

## Verify the guard

```bash
# On main: expect exit 1 and the git-guard message.
git commit --allow-empty -m "guard check"
# On a branch: expect exit 0.
git checkout -b tmp/guard-check && git commit --allow-empty -m "guard check"
git checkout main && git branch -D tmp/guard-check
```
