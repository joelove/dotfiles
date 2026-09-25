---
name: shell-context
description: Shell facts for pi's bash tool (non-interactive zsh 5.9). Use before generating shell commands or tool calls that depend on the environment.
disable-model-invocation: true
---

# Shell context

- Pi's `bash` tool runs `/bin/zsh -c` non-interactively, despite the tool name.
  Write zsh-compatible syntax, and do not assume bash.
- Interactive rc files are not sourced, so aliases and functions are unavailable
  by default. For a user function, run
  `source ~/.zshrc >/dev/null 2>&1 || true` first. Aliases then need `eval`.
- The inherited environment already has the right `PATH`; do not source for
  trivial commands.
- Prefer the dedicated tools (`read`, `edit`, `write`, `grep`, `find`, `ls`)
  over shell equivalents.

Full environment inventory (shell version, rc files, PATH, aliases, user
commands): [references/environment.md](references/environment.md).
