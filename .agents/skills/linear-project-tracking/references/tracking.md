# Linear tracking: projects, tools, estimates

## Planning phase

1. Search for an existing project with `list_projects` (`query` matching the
   feature). If a match exists, present it to the user for confirmation.
2. If none, offer to create one with `save_project`:
   - `name`, `summary` (max 255 chars), `description` (markdown), `addTeams`.
   - A unique `icon` and a random hex `color`. List existing projects first and
     pick an icon none of them use. `icon` is an icon name or emoji code
     (`"Rocket"`, `":eagle:"`), not a raw Unicode emoji.
   - `state` "planned" or "started" as appropriate.
3. Keep the description rich but terse: goal, scope, key constraints, short
   bullets. No filler.

## Tool reference

| Action | Operation | Key params |
|--------|------|-----------|
| Search projects | `list_projects` | `query` |
| Get project details | `get_project` | `query` |
| Get issue (incl. `gitBranchName`) | `get_issue` | `id` |
| Create/update project | `save_project` | `name`, `description`, `addTeams`, `state`, `icon`, `color` |
| Project status update | `save_status_update` | `type: "project"`, `project`, `body`, `health` |
| Create/update issue | `save_issue` | `title`, `description`, `team`, `project`, `parentId`, `state`, `assignee`, `estimate` |
| List issues | `list_issues` | `project`, `state`, `team` |
| Add comment | `save_comment` | `issueId`, `body` |
| List teams | `list_teams` | -- |

## Notes

- Use literal newlines in markdown content; do not escape them.
- When unsure of the team name, call `list_teams` first.
- Issue identifiers look like `TEAM-123`; use them for `id`, `parentId`, and so
  on.
- `get_issue` returns `gitBranchName` (for example
  `joe/can-453-rename-aws-resources-and-terraform-stacks`). That is the only
  allowed feature-branch name. See git-sync-from-main.
- Prefer updating existing issues over creating duplicates; search first.
- Required on every new issue: `assignee: "Joe Love"` and `estimate`
  (Fibonacci: 1, 2, 3, 5, 8). Required on every new project: a unique `icon`
  and a random hex `color`.

## Estimates

Linear hides Estimate in the UI until the team opts in. Projects do not have
their own estimate setting.

- Prerequisite: your Linear team -> Team Settings -> General -> Estimates, scale
  Fibonacci (1, 2, 3, 5, 8). The `save_issue` `estimate` field can persist even
  when the UI toggle is off, so a successful create is not proof the team can
  see points.
- On every `save_issue` create, pass `estimate`, then check the response has
  `estimate` (`value` + `name`). If missing, stop and tell the user to enable
  Estimates on the team.
- If the user cannot see estimates after a create, the usual cause is the team
  toggle or the view not showing the Estimate column (Display -> Estimate), not
  a missing API field.

## Reconcile missed closes

The GitHub integration closes issues on merge, so closing is not an agent step.
When it misses one (a dropped webhook, or a PR that never linked), find it from
GitHub, where the merged PR is the source of truth.

1. List merged PRs in the window and collect every `CAN-XXXX` id from the branch,
   title, and body. Run from the workspace root:

       for repo in candela-eval candela-orchestrator candela-cms candela-ui \
                   candela-materials candela-infra candela-qa; do
         gh pr list --repo Candela-Ed/$repo --state merged --limit 200 \
           --json number,title,headRefName,mergedAt,body \
           --jq '.[] | [.mergedAt, "'$repo'", (.number|tostring), .headRefName, .title, (.body // "")] | @tsv'
       done | grep -E '2026-09-2[3-9]' | grep -oiE 'can-[0-9]+' | tr 'a-z' 'A-Z' | sort -u

2. For each id, read the issue with the Linear MCP `get_issue`. For the gateway
   the issue JSON is in `data.content[0].text`. If `statusType` is `completed` or
   `canceled`, leave it.

3. For each remaining id, confirm the merged PR is the primary link: the id is in
   the branch or title, or the body has a `Closes CAN-XXXX` line. A follow-up
   mention in a body is not a close. Close a genuine miss with `save_issue`
   (`id`, `state: "Done"`).

4. Also scan the window's merged PRs with no `can-` id in any case (chore and
   release PRs often have none). If one finished an open issue, close that issue
   and note the PR in a comment.

Expected result: no genuine misses. An id a PR body merely mentions without
linking (no id in the branch or title, no `Closes` line) stays as it is. In the
current workspace the last seven days flag only follow-ups (CAN-1104, CAN-1187,
CAN-1188, CAN-1207) and the duplicate CAN-1129; every linked merged PR already
closed its issue.

### Auto-close settings

In Linear: Settings to Team to Workflows & automations to Pull request and commit
automations. Set "On PR or commit merge" to Done, and optionally "On PR review
request or activity" to In Review.

Magic words for the PR description: closing are close, fix, resolve, complete,
implement, and "linear issue"; non-closing are ref, part of, contributes to,
toward, and updates. The issue id in the branch name or PR title links the PR on
its own, and the merge automation still applies, so keep the id in every PR.
