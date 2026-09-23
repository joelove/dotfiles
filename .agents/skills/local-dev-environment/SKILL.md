---
name: local-dev-environment
description: >-
  Architecture, invariants and configuration map of Joe's local macOS dev
  environment: Ghostty, tmux, zsh, Neovim (NvChad + octo.nvim), gh-dash,
  dev-workspace, skhd/yabai and the pi agent. Use before changing any local
  tool config, dotfiles file, terminal/editor keybinding or the tmux editor
  layout, and when debugging the workspace, sessions, restores or keybindings.
  Triggers on: ghostty, tmux, nvim/nvchad/octo, gh-dash, dev-workspace,
  dotfiles, skhd, yabai, zsh config, local environment, pane layout.
---

# Local development environment

`dev-workspace` (a generic bash engine) builds tmux/Ghostty workspaces from
per-project profiles. A workspace is two tmux sessions in two Ghostty windows:
an agent view (pi panes) and an editor view (nvim + a review pane + terminal
shells). Ghostty is a thin front end; tmux owns panes; zsh/oh-my-zsh/p10k is the
shell; Neovim is NvChad v2.5 with octo.nvim for PR review; skhd/yabai manage
windows and spaces. Everything is configured from `~/Projects/dotfiles`,
symlinked into `$HOME`. See `references/architecture.md` for the exhaustive
per-tool detail.

## Invariants (do not break)

- `~/Projects/dotfiles` is the single source of truth: home paths are symlinks; edit in the repo, then commit and push.
- Ghostty is a thin front end. tmux owns panes/splits; never add Ghostty/AppleScript splits.
- `cmd` never reaches the terminal. GUI shortcuts are bridged: Ghostty keybind sends `Alt+<key>` (`text:\x1b...`), tmux forwards it, Neovim maps `<A-...>`.
- Workspaces are data: a profile (`~/.config/dev-workspace/<name>.conf`) sets directories, commands and sizes; the engine has no project-specific code. Adding a project is a profile plus a one-line wrapper. Panes are the same: `DEV_TERM_DIRS` plus parallel `DEV_TERM_CMDS`, and a `DEV_REVIEW_SUB_CMD` stacked below the review pane.
- The editor layout is pinned deterministically: `build_editor` creates it and `normalize_editor` re-applies the review pane width (`DEV_GH_COLS`) and bottom row height (`DEV_BOTTOM_LINES`). Change sizes only in the profile.
- `dev-workspace` owns the lifecycle: `open`, `build`, `ensure`, `attach`, `review`, `normalize-editor`, `post-restore`; project wrappers are one-line `exec dev-workspace <profile> "$@"`.
- tmux-resurrect restores panes but not pane options or pinned sizes, so `normalize_editor` re-applies sizes and re-tags the editor pane (`@dev_review_pane <profile>`); the global hooks call `dev-workspace ... --all`.
- Neovim: NvChad v2.5, leader = space; octo.nvim reviews, gh-dash triages.
- gh-dash is per profile: the default config lists all `user:joelove` PRs; a project profile can point `gh dash --config` at its own config.
- Palette stays consistent: Ghostty monokai palette, tmux-nova `#2a2a2a` borders, nvim theme `ghostty`.
- Never commit secrets. `mcp.json`'s GitHub token is `!gh auth token`.

## Configuration map (dotfiles path -> what it configures)

| Path | Configures |
| --- | --- |
| `.local/bin/dev-workspace` | generic workspace engine (sessions, layout, Ghostty windows, review helper) |
| `.local/bin/running-actions` | live in-progress Actions view for a dev-workspace bottom pane |
| `.local/bin/*-workspace` | per-project one-line wrappers over a profile |
| `.config/dev-workspace/*.conf` | per-project profiles |
| `.config/dev-workspace/*.yml` | per-project gh-dash configs |
| `.config/ghostty/config` | Ghostty theme, cursor, tmux keybinds, cmd->Alt bridges |
| `.tmux.conf` | status/nova, tpm plugins, mouse, titles, cursor, extended-keys, hooks |
| `.config/gh-dash/config.yml` | gh-dash default profile (all `user:joelove` PRs) |
| `.config/nvim/**` | NvChad config, mappings, cursor, octo, nvim-tree, theme |
| `.agents/skills/*/SKILL.md` | agent skills (github-prs, local-dev-environment) |
| `.skhdrc` / `.automations.sh` / `.yabairc` | hotkeys, yabai sizing/space helpers, yabai signals |
| `.zshrc` / `.zprofile` / `.zshenv` / `.p10k.zsh` | shell, aliases (`v`/`code`/`c` -> nvim), PATH, EDITOR |
| `.gitconfig` | git identity + gh credential helper |
| `.config/karabiner/`, `qmk/` | keyboard remaps and QMK keymaps |

pi lives outside dotfiles: `~/.pi/agent/{settings.json,mcp.json,agents,extensions,themes}`; skills are symlinked from `~/.agents/skills`.

## Reload / debug

| Tool | Reload | Inspect |
| --- | --- | --- |
| Ghostty | `cmd+shift+,` or restart | `ghostty +validate-config`, `+list-keybinds` |
| tmux | `prefix r` or `tmux source-file ~/.tmux.conf` | `tmux show-options -g`, `show-hooks -g`, `list-keys -T prefix` |
| dev-workspace | `bash -n`, `dev-workspace <profile> print-config` | `dev-workspace [<profile>] ensure`, `normalize-editor` |
| Neovim | restart nvim, `:Lazy` | `:checkhealth octo` (after `:Octo` loads) |
| gh-dash | relaunch `gh dash` (config read at launch) | gh-dash schema |
| skhd | `skhd --reload` | `/tmp/skhd_joelove.{out,err}.log` |
| yabai | `yabai --restart-service` | `.automations.sh` helpers |
| gh | - | `gh auth status` |

## Known pitfalls

- A shell variable named `TMUX` shadows tmux's socket env; `dev-workspace` uses `TMUX_BIN`.
- `extended-keys` / `terminal-features` changes only take effect on a new client attach (restart/re-attach tmux).
- resurrect restores the saved (often old) layout and drops pane options; `normalize_editor` is what fixes it.
- Ghostty `text:` keybinds use Zig escapes (single backslash) and comments must be on their own lines.
- Neovim cannot see `cmd`; bridge every GUI shortcut via Ghostty -> `Alt`.
- octo is lazy (`cmd = "Octo"`), so `:checkhealth octo` needs it loaded first.
- gh-dash reads config at launch; `o` overrides its built-in open-in-browser.
- The editor pane's cwd is a project root that may not be a git repo; octo needs explicit repo/URL.

## How to change safely

1. Edit the file in `~/Projects/dotfiles`, never the symlink target directly.
2. Validate with the tool's check from the table above.
3. Reload/restart the tool and confirm the behaviour.
4. Commit and push `~/Projects/dotfiles`.
5. Keep coupled changes together: a new shortcut needs both the Ghostty bridge and the nvim `<A-...>` map; a layout size is a profile field, not engine code.

## Related skills

- `github-prs` (PR create + open review), `review-code`, `autopilot`, `create-skill`, `shell-context`.
