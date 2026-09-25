---
name: shell
description: >-
  Runs the rest of a /shell request as a literal shell command via pi's bash
  tool. Use only when the user explicitly invokes /skill:shell and wants the
  following text executed directly in the terminal.
disable-model-invocation: true
---

# Run shell commands

Use this skill only when the user explicitly invokes `/skill:shell`.

## Behavior

1. Treat all user text after the invocation as the literal shell command to run.
2. Execute that command immediately with the `bash` tool.
3. Do not rewrite, explain, or "improve" the command before running it.
4. Do not inspect the repository first unless the command itself requires repository context.
5. If the user invokes `/shell` without any following text, ask them which command to run.

pi's `bash` tool runs `/bin/zsh -c "<command>"` non-interactively, so aliases and functions from `~/.zshrc` are not loaded. If the command depends on them, source the config yourself (for example `source ~/.zshrc >/dev/null 2>&1 || true`) or use the underlying command.

## Response

- Run the command first.
- Then briefly report the exit status and any important stdout or stderr.
