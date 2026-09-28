---
name: local-dev-environment
description: Architecture, invariants, and configuration map of Joe's local macOS dev environment (Ghostty, tmux, zsh, croft, gh-dash, dev-workspace, skhd/yabai, pi). Use before changing local tool config, dotfiles, terminal/editor keybindings, or the tmux editor layout, and when debugging the workspace.
---

# Local development environment

`dev-workspace` (a generic bash engine) builds tmux/Ghostty workspaces from
per-project profiles. A workspace is two tmux sessions in two Ghostty windows:
an agent view (pi panes) and an editor view (croft + a review pane + terminal
shells). Ghostty is a thin front end; tmux owns panes; zsh/oh-my-zsh/p10k is the
shell; croft is the VS Code-style terminal editor wearing a custom Monokai theme
that matches the terminal palette; skhd/yabai manage windows. All config lives
in `~/Projects/dotfiles`, symlinked into `$HOME`.

Per-tool detail: [references/architecture.md](references/architecture.md).
Config map, reload/debug, and pitfalls:
[references/operations.md](references/operations.md).

## Invariants (do not break)

- `~/Projects/dotfiles` is the single source of truth: edit in the repo, never
  the symlink target, then commit and push.
- Ghostty is a thin front end. tmux owns panes and splits; never add
  Ghostty/AppleScript splits.
- `cmd` never reaches the terminal. croft's managed Ghostty block
  (`croft setup-ghostty`) re-emits croft's Cmd chords as CSI-u, and tmux's
  `extended-keys on` + `extended-keys-format csi-u` carries them to croft. The
  colliding pane chords (`Cmd+D`, `Cmd+Shift+D`, `Cmd+W`, `Cmd+Shift+Enter`,
  `Cmd+Alt+arrows`) are excluded from that block and sent through tmux's `croft`
  key table instead, which gives them to croft when it is focused and runs the
  pane action otherwise. Never hand-edit between the block's markers; re-run
  `croft setup-ghostty` and re-remove those pane chords.
- Workspaces are data: a profile (`~/.config/dev-workspace/<name>.conf`) sets
  directories, commands, and sizes; the engine has no project-specific code.
- The editor layout is pinned. `build_editor` creates it and `normalize_editor`
  re-applies the review width (`DEV_GH_COLS`) and bottom row height
  (`DEV_BOTTOM_LINES`). Change sizes only in the profile.
- tmux-resurrect restores panes but not pane options or pinned sizes, so
  `normalize_editor` re-applies them; global hooks call `dev-workspace ... --all`.
- Palette stays consistent: Ghostty monokai, tmux-nova `#2a2a2a` borders, croft
  `monokai-terminal` (its 16-entry `ansi` array is the Ghostty palette).
- croft has no ANSI-passthrough mode; a theme is RGB hex, so any Ghostty palette
  change must be mirrored into the croft theme's `ansi` array.
- Never commit secrets. `mcp.json`'s GitHub token is `!gh auth token`.
- pi lives outside dotfiles: `~/.pi/agent/{settings.json,mcp.json,agents,extensions,themes}`;
  skills are discovered from `~/.agents/skills`.

## How to change safely

1. Edit the file in `~/Projects/dotfiles`, never the symlink.
2. Validate with the tool's check (see references/operations.md).
3. Reload/restart the tool and confirm the behaviour.
4. Commit and push `~/Projects/dotfiles`.
5. Keep coupled changes together: a new croft shortcut goes in croft's
   `keybindings.json`, then `croft setup-ghostty` re-emits it; a layout size is a
   profile field, not engine code.
