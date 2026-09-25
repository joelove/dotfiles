---
name: create-skill
description: >-
  Author Agent Skills for pi: a SKILL.md with frontmatter plus optional
  reference files and scripts that teach the agent a specific workflow. Use
  when creating a new skill, converting a rule or slash command into a skill,
  or asking about SKILL.md structure, frontmatter fields, skill locations, or
  progressive disclosure.
---

# Creating Skills in pi

Skills are directories with a `SKILL.md` file that teach the agent how to perform a task. pi follows the Agent Skills standard: only `name` and `description` load at startup, and the body loads on demand.

## Before you begin

Gather:

1. **Purpose and scope** - what specific task does this skill help with?
2. **Location** - personal (all projects) or project (this repo)?
3. **Trigger scenarios** - when should the agent apply it?
4. **Domain knowledge** - what does the agent not already know?
5. **Output format** - templates, formats, styles?
6. **Existing patterns** - examples or conventions to follow?

If the user supplies exact wording, use it verbatim.

Use pi's `question` tool for fixed choices (location, whether to include scripts).

## Locations

| Type | Path | Scope |
|---|---|---|
| Personal (pi) | `~/.pi/agent/skills/<name>/` | All projects |
| Personal (shared) | `~/.agents/skills/<name>/` | All projects, other harnesses |
| Project (pi) | `.pi/skills/<name>/` | This repo |
| Project (shared) | `.agents/skills/<name>/` | This repo, other harnesses |

Prefer `~/.agents/skills/` for skills pi, Claude Code, and other Agent Skills harnesses should share. `~/.pi/agent/skills/` is pi-only.

pi also loads skills from packages, the `skills` array in settings, and `--skill <path>`. Do not create the same skill name in two discovered locations: pi warns on name collisions and keeps the first found.

## Structure

```
skill-name/
|-- SKILL.md              # required
|-- references/           # optional detail, read on demand
|-- scripts/              # optional helper scripts
|-- assets/               # optional templates
```

## Frontmatter

| Field | Required | Notes |
|---|---|---|
| `name` | yes | 1-64 chars, lowercase `a-z`, `0-9`, hyphens; no leading/trailing/consecutive hyphens |
| `description` | yes | Max 1024 chars; include WHAT and WHEN |
| `disable-model-invocation` | no | `true` hides it from the system prompt; the user must run `/skill:<name>` |
| `license`, `compatibility`, `metadata`, `allowed-tools` | no | Optional per the standard |

Unknown fields are ignored.

```markdown
---
name: your-skill-name
description: What the skill does and when to use it.
---
```

## Writing the description

Write in third person, be specific, and include both WHAT and WHEN plus trigger terms.

- Good: "Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or forms."
- Bad: "Helps with documents."

## Authoring principles

- **Concise is key.** The agent is already capable; only add what it does not know. Keep `SKILL.md` under 500 lines.
- **Progressive disclosure.** Essentials in `SKILL.md`; detailed reference material in separate files linked one level deep.
- **Match freedom to fragility.** High (prose instructions) for judgement calls, medium (templates) for preferred patterns, low (scripts) for fragile operations.
- **Use relative paths** from the skill directory, e.g. `references/REFERENCE.md`.
- **No time-sensitive content.** Prefer "current" and "old patterns" sections over dated instructions.
- **Consistent terminology**, concrete examples, forward slashes in paths.

## Patterns

- **Template** - provide the exact output shape.
- **Examples** - input to output pairs when quality depends on seeing examples.
- **Workflow** - numbered steps with a checklist.
- **Conditional workflow** - branch by decision point.
- **Feedback loop** - run a validator, fix, repeat.

## Workflow

1. Choose the location.
2. Write a specific third-person description.
3. Outline sections; add reference files only when needed.
4. Write `SKILL.md`.
5. Verify: under 500 lines, references one level deep, no broken relative paths, consistent terminology.
6. Test with `/skill:<name>` or by describing the trigger.
