---
name: linear-project-tracking
description: Track work in Linear. Create projects and issues, update progress, and close them out. Use when planning a feature, starting or completing a task, or logging a code change in any repo in your workspace.
---

# Linear project tracking

Linear is the MCP server `linear`. Reach it through the `mcp` gateway
(`mcp({ tool, args })`) or direct tools if enabled. Every code change is logged
in Linear.

## Workflow

1. **Planning**: find or create a project for the feature.
2. **Plan confirmed**: create top-level issues and sub-issues.
3. **Working**: update the issue state and post progress comments.
4. **Completion**: close issues; close the project when its last issue is done.

## Accessing Linear

- Discover tools: `mcp({ search: "issue" })` (also `project`, `comment`,
  `team`).
- Call: `mcp({ tool: "<name>", args: { ... } })`.
- Operation names used below (`list_issues`, `get_issue`, `save_issue`, ...)
  map to whatever the gateway reports for the `linear` server.

## Create issues (plan confirmed)

For each top-level task, `save_issue` with:

- `title`, `description`, `team`, and `project` (name or id from step 1).
- `assignee: "Joe Love"` always.
- `estimate`: always set on create. Fibonacci: 1 trivial, 2 small, 3
  half-day, 5 a day, 8 multi-day. If unsure, use 2.
- `priority`: 2 (High) blocking, 3 (Medium) standard, 4 (Low) polish.
- `description`: one-sentence goal, then acceptance criteria or steps, and file
  paths where useful. No filler.

For each sub-step, `save_issue` with the same fields plus `parentId`.

Add `blockedBy` / `blocks` where tasks have ordering dependencies.

If a new issue's response comes back without `estimate`, stop and tell the user
to enable Estimates on your Linear team (Fibonacci). Do not keep creating
unestimated issues.

## Working

1. Set state In Progress with `save_issue` (`state: "In Progress"`,
   `assignee: "Joe Love"`). If code will change, read git-sync-from-main and
   branch first.
2. Post updates with `save_comment` (`issueId`, `body`): findings, decisions,
   blockers. Terse, one comment per meaningful update.

Comment style: first line a bold summary, then 2-5 bullets. No greetings or
sign-offs.

## Completion

1. `save_issue` with `id` and `state: "Done"`.
2. Run the linear-worktrees sweep, even if you never made a worktree.
3. Post a final comment if warranted.
4. Close a parent when all its sub-issues are done.
5. If it was the project's last open issue, post a `save_status_update`
   (`type: "project"`, `health: "onTrack"`) and set the project Done with
   `save_project`.

Project creation detail, the full tool table, and the Estimates setup:
[references/tracking.md](references/tracking.md).
