---
name: migrate-to-skills
description: >-
  Convert Cursor rules (.cursor/rules/*.mdc) and slash commands
  (.cursor/commands/*.md, .claude/commands/*.md) into pi Agent Skills. Use when
  the user wants to migrate rules or commands to skills, convert .mdc rules to
  SKILL.md format, or consolidate commands into a skills directory.
disable-model-invocation: true
---

# Migrate Rules and Slash Commands to Skills

Convert Cursor rules, Claude commands, and similar prompt files into Agent Skills.

**CRITICAL: Preserve the exact body content. Do not modify, reformat, or "improve" it - copy verbatim.**

## Locations

| What | Source | Destination |
|---|---|---|
| Cursor rules | `{workspace}/**/.cursor/rules/*.mdc` | `.pi/skills/` or `~/.pi/agent/skills/` |
| Cursor commands | `.cursor/commands/*.md` | `.pi/skills/` or `~/.pi/agent/skills/` |
| Claude commands | `.claude/commands/*.md`, `~/.claude/commands/*.md` | `.pi/skills/` or `~/.pi/agent/skills/` |

Use `~/.agents/skills/` instead of the `.pi` locations when the skill should also be readable by other Agent Skills harnesses. Prefer project scope for repo-specific workflows and user scope for personal ones.

Notes:

- Cursor project rules can live in nested directories. Search with globs and be thorough.
- Ignore anything under `~/.cursor/worktrees`.
- Ignore `~/.cursor/skills-cursor`; it is Cursor's managed built-in directory.

## Finding files to migrate

- **Cursor rules**: migrate if the rule has a `description` but no `globs` and no `alwaysApply: true`.
- **Commands** (Cursor or Claude): migrate all; they are plain markdown without skill frontmatter.

## Conversion format

### Cursor rule (.mdc) -> SKILL.md

Before:

```markdown
---
description: What this rule does
globs:
alwaysApply: false
---
# Title
Body content...
```

After (`<dest>/my-rule/SKILL.md`):

```markdown
---
name: my-rule
description: What this rule does
---
# Title
Body content...
```

Changes: add `name`, remove `globs` and `alwaysApply`, keep the body exactly.

### Command (.md) -> SKILL.md

Before (`~/.cursor/commands/commit.md`):

```markdown
# Commit current work
Instructions here...
```

After (`<dest>/commit/SKILL.md`):

```markdown
---
name: commit
description: Commit current work with a standardized message format
disable-model-invocation: true
---
# Commit current work
Instructions here...
```

Changes: add frontmatter with `name` (from the filename), an inferred `description`, and `disable-model-invocation: true` (commands are meant to be invoked explicitly, not auto-selected), keep the body exactly.

## Workflow

1. Create the destination skills directory if needed.
2. Find files to migrate in the sources above. Use the `read` tool; do not use the terminal to read files.
3. Build the list. If empty, stop.
4. For each file, read it, then write the new skill directory and `SKILL.md` with the body preserved exactly. Use the `write` tool; do not write via the shell.
5. Do not delete the originals unless the user asks. If they ask to undo, restoring is then trivial.
6. Summarize the migrated files and their new locations. Tell the user which originals were left in place.

If the subagent extension is installed, you may dispatch the per-category work to subagents; otherwise do it directly.
