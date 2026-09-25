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
