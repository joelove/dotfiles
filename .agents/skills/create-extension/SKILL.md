---
name: create-extension
description: >-
  Create pi extensions: TypeScript modules that add tools, commands, event
  handlers, permission gates, context injection, or custom UI. Use when the
  user wants to create a pi extension, hook into pi events, block or modify
  tool calls, add a slash command, inject context, or convert a Cursor hook
  (hooks.json) or Claude Code hook into pi behavior.
disable-model-invocation: true
---

# Creating pi extensions

pi extensions are TypeScript modules that extend pi. They can observe or block tool calls, inject context, register tools and commands, and persist state. An extension is the pi equivalent of a Cursor hook.

Before writing one, read the full API in the pi docs (`docs/extensions.md`) and the working examples (`examples/extensions/`) under the installed `@earendil-works/pi-coding-agent` package.

## Gather requirements

Infer from the conversation when possible; ask only for what is missing.

1. **Trigger** - which event or tool call should fire the behavior?
2. **Behavior** - observe, block, modify input, inject context, or add a new capability?
3. **Scope** - global (`~/.pi/agent/extensions/`) or project (`.pi/extensions/`)?
4. **State** - does it need to persist across turns or restarts?
5. **Failure mode** - if it throws, should the action fail open or closed?

## Locations

| Location | Scope |
|---|---|
| `~/.pi/agent/extensions/*.ts` | Global, all projects |
| `~/.pi/agent/extensions/<name>/index.ts` | Global bundle |
| `.pi/extensions/*.ts` | Project-local (project must be trusted) |
| `.pi/extensions/<name>/index.ts` | Project bundle |

Auto-discovered extensions hot-reload with `/reload`. Use `pi -e ./file.ts` only for quick tests.

## Skeleton

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function (pi: ExtensionAPI) {
  // Observe or block a tool call.
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName === "bash" && event.input.command?.includes("rm -rf")) {
      const ok = await ctx.ui.confirm("Dangerous!", "Allow rm -rf?");
      if (!ok) return { block: true, reason: "Blocked by user" };
    }
  });

  // Register a tool the model can call.
  pi.registerTool({
    name: "greet",
    label: "Greet",
    description: "Greet someone by name",
    parameters: Type.Object({ name: Type.String() }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      return { content: [{ type: "text", text: `Hello, ${params.name}!` }], details: {} };
    },
  });

  // Register a slash command.
  pi.registerCommand("hello", {
    description: "Say hello",
    handler: async (args, ctx) => ctx.ui.notify(`Hello ${args || "world"}!`, "info"),
  });
}
```

## Cursor hook mappings

| Cursor hook | pi |
|---|---|
| `preToolUse`, `beforeShellExecution`, `beforeMCPExecution` | `pi.on("tool_call", ...)`, return `{ block: true, reason }` |
| `postToolUse`, `afterFileEdit`, `afterShellExecution` | `pi.on("tool_execution_end", ...)` or `pi.on("tool_result", ...)` |
| `beforeSubmitPrompt` | `pi.on("input", ...)` |
| `sessionStart` | `pi.on("session_start", ...)` |
| `sessionEnd` | `pi.on("session_shutdown", ...)` |
| `stop`, agent completion | `pi.on("agent_end", ...)` or `pi.on("agent_settled", ...)` |
| custom command | `pi.registerCommand(...)` |
| prompt hook | an extension that calls the model via `ctx.modelRegistry` or exposes a custom tool |

## Common events

- `tool_call` - before a tool runs; can block or modify input.
- `tool_result` - after a tool returns; can transform or annotate the result.
- `input` - before a user prompt is sent; can modify or block.
- `user_bash` - user-typed shell commands.
- `session_start`, `session_shutdown`, `agent_start`, `agent_end`, `turn_start`, `turn_end`.
- `resources_discover` - add skills, prompts, themes, extensions.
- `model_select`, `thinking_level_select`, `before_provider_request`.

## Notes

- Extensions run with full system permissions. Only install trusted code, and tell the user that.
- Use `pi.appendEntry(customType, data)` to persist state across restarts.
- `ctx.ui.notify/confirm/select/input` for interaction; branch on `ctx.mode` and `ctx.hasUI`.
- Keep handlers cheap and return early; a matcher-style guard is cheaper than work inside the handler.
- Extension commands are invoked as `/name`; registered tools are callable by the model.

## Workflow

1. Pick the event and location.
2. Write the smallest handler that works.
3. Test with `pi -e ./file.ts`, then trigger the real event.
4. Move it to an auto-discovered location and `/reload`.
5. Verify the behavior and that failures fail the way you intended.
