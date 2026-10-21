# Agent essentials

## Copy

Never write an em dash (U+2014) or a double hyphen used as a dash in anything a
person reads: chat replies, docs, slides, UI text, commit messages, marketing
copy. Replace it with the punctuation that fits: colon, semicolon, comma,
parentheses, or a second sentence. Do not just swap the character, rewrite the
sentence. Detail: `/skill:no-em-dashes`.

## Shell

Pi's `bash` tool runs `/bin/zsh -c` non-interactively (zsh 5.9), despite the
tool name. Interactive rc files are not sourced, so aliases and functions are
unavailable by default. Write zsh-compatible syntax and prefer real commands
(`ls -lah`, `git status`, `bat -p`) over aliases. For a user function or alias,
run `source ~/.zshrc >/dev/null 2>&1 || true` first; aliases then need `eval`.
Prefer the dedicated file tools (`read`, `edit`, `write`, `grep`, `find`) over
shell equivalents. Detail: `/skill:shell-context`.

## Git

Never commit or push on `main` or `master`. Branch from the tip of `main`
first. A global hook enforces this. Detail: `/skill:git-guard`.

## Plan tools

`plan_task`, `plan_complete`, and `plan_finish` are pi harness tools. Call
them directly as tool calls. Never route them through the `mcp` gateway or
`mcpScript`; those reach MCP servers (`linear`, `github`) only.
A `Tool not found` from `mcp({ tool: "plan_complete" })` or a `ReferenceError`
from `tools.plan_complete(...)` means the wrong transport, not a missing tool.
Do not search MCP for a plan tool; call it directly. `plan_complete` closes the
plan only when all approved work and checks pass, while `plan_finish` records
unfinished outcomes (`awaiting_validation`, `blocked`, `waiting_for_input`,
`still_working`).

## Avoid tool loops

- Never chain small-offset reads. When a tool result ends with "Use offset=X to
  continue", either read the remainder in one call or stop reading.
- When a plan is active and its approved work and checks are done, call
  `plan_finish` (or `plan_complete`) before the final summary. Do not re-read
  files to verify; the plan context already asks for the outcome.
