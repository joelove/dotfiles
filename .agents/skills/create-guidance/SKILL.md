---
name: create-guidance
description: >-
  Author persistent guidance for pi: global or project AGENTS.md context files,
  AGENTS.override.md, and when to use an on-demand skill instead. Use when you
  want to add coding standards, project conventions, always-on instructions,
  or convert Cursor .mdc rules or Claude rules into pi context files.
disable-model-invocation: true
---

# Authoring agent guidance

pi loads persistent guidance from context files at startup; guidance that only sometimes applies belongs in a skill.

## Where guidance goes

| Mechanism | Path | Loaded |
|---|---|---|
| Global context | `~/.pi/agent/AGENTS.md` | Every session, all projects |
| Project context | `AGENTS.md` or `CLAUDE.md` from cwd up to the git root and parents | When working in that tree |
| Override | `AGENTS.override.md` | Replaces `AGENTS.md`/`CLAUDE.md` in that directory only |
| On-demand | a skill | Only when its description matches |

`--no-context-files` disables context discovery.

## Context file vs skill

- **Context file**: short, always-relevant facts (language, package manager, commands, conventions, safety rules). It costs tokens every session, so keep it tight.
- **Skill**: a workflow for a specific task, loaded only when needed. Prefer a skill for anything longer than a screen or only sometimes relevant.

If guidance is conditional ("when writing migrations, do X"), make it a skill with a clear description. If it is a standing constraint ("never commit to main"), put it in `AGENTS.md`.

## Converting Cursor rules

Cursor `.mdc` rules map like this:

- `alwaysApply: true` -> a line in `AGENTS.md` (always-on).
- A rule with `description` and `globs`/no `alwaysApply` -> a skill. Move the body into `SKILL.md` and keep the `description`.
- Several file-scoped rules -> one skill with sections, or one skill per concern.

Preserve the body verbatim; change only the frontmatter. See `create-skill` for the skill format.

## Writing guidance

- Keep `AGENTS.md` short: facts and imperatives, not tutorials.
- One concern per section; use headings the agent can match on.
- Prefer concrete commands and file paths over abstractions.
- Do not duplicate what a skill already says.
- Never overwrite unrelated content in an existing context file.

## Workflow

1. Decide context file vs skill.
2. **Context**: append a focused section to the global or project `AGENTS.md`.
3. **Skill**: create `~/.pi/agent/skills/<name>/SKILL.md` (or the shared `.agents` location) following `create-skill`.
4. Re-read the result and cut anything the agent already knows.
