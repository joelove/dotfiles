---
name: create-subagent
description: >-
  Create pi subagent definitions for the subagent extension: markdown files with
  frontmatter and a system prompt in ~/.pi/agent/agents/ or .pi/agents/. Use
  when creating a specialized subagent, code reviewer, debugger, scout, or
  domain assistant, or converting a Cursor subagent.
disable-model-invocation: true
---

# Creating pi subagents

Subagents run in isolated `pi` processes with their own context window and system prompt. They are defined as markdown files and invoked through the `subagent` tool from pi's subagent extension.

## Prerequisite

The subagent extension must be installed. It lives at `examples/extensions/subagent/` in the pi install; copy or symlink `index.ts` and `agents.ts` into `~/.pi/agent/extensions/subagent/`. It discovers agents from `~/.pi/agent/agents/*.md` and, when enabled, `.pi/agents/*.md`.

## When to use a subagent

- Preserve context by isolating exploration from the main conversation.
- Specialize behavior with a focused system prompt.
- Reuse a configuration across projects with a user-level agent.

## Locations

| Location | Scope |
|---|---|
| `~/.pi/agent/agents/*.md` | User, all projects |
| `.pi/agents/*.md` | Project (requires `agentScope` `"project"` or `"both"`) |

When names collide, project agents win in `both` mode.

## File format

```markdown
---
name: code-reviewer
description: Expert code review specialist. Use immediately after writing or modifying code.
tools: read, grep, find, ls, bash
model: claude-sonnet-4-5
---

You are a senior code reviewer. When invoked:

1. Run `git diff` to see recent changes.
2. Read the modified files.
3. Report bugs, security issues, and smells by severity with `file:line` references.
```

Required and optional fields:

| Field | Notes |
|---|---|
| `name` | Unique identifier, lowercase letters and hyphens |
| `description` | How the model decides to delegate; make it specific and include trigger terms |
| `tools` | Comma-separated list or YAML array; restrict to what the agent needs |
| `model` | Optional; omit to inherit the parent model |

The body is the system prompt. Be specific about the job, the process, the output format, and any constraints.

## Invocation

The `subagent` tool supports three modes:

- single: `{ "agent": "reviewer", "task": "..." }`
- parallel: `{ "tasks": [{ "agent": "scout", "task": "..." }, ...] }`
- chain: `{ "chain": [{ "agent": "planner", "task": "... {previous} ..." }] }`

In a chain, `{previous}` is replaced with the prior agent's output.

## Best practices

- Design one focused job per subagent.
- For reviewers, grant read-only tools and forbid file edits in the prompt.
- Write a detailed description with the terms a user would actually say.
- Keep the system prompt specific and terse; it is loaded on every invocation.
- Include "use proactively" in the description when you want automatic delegation.

## Workflow

1. Decide the scope (user vs project).
2. Create `~/.pi/agent/agents/<name>.md`.
3. Write the frontmatter (`name`, `description`, `tools`, `model`).
4. Write the system prompt.
5. Test by asking pi to use the agent, e.g. "Use the reviewer subagent to check the current diff."
