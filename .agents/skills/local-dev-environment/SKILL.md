---
name: local-dev-environment
description: >-
  Architecture, invariants and configuration map of Joe's local macOS dev
  environment: Ghostty, tmux, zsh, Neovim (NvChad + octo.nvim), gh-dash,
  candela-workspace, skhd/yabai and the pi agent. Use before changing any local
  tool config, dotfiles file, terminal/editor keybinding or the tmux editor
  layout, and when debugging the workspace, sessions, restores or keybindings.
  Triggers on: ghostty, tmux, nvim/nvchad/octo, gh-dash, candela-workspace,
  dotfiles, skhd, yabai, zsh config, local environment, pane layout.
---

# Local development environment

Two tmux sessions run side by side in two Ghostty windows: `candela-pi` (agent:
two `pi` panes) and `candela-prs` (editor: nvim + gh-dash + two shells). Ghostty
is a thin front end; tmux owns panes; zsh/oh-my-zsh/p10k is the shell; Neovim is
NvChad v2.5 with octo.nvim for PR review; skhd/yabai manage windows and spaces.
Everything is configured from `~/Projects/dotfiles`, symlinked into `$HOME`.
See `references/architecture.md` for the exhaustive per-tool detail.

## Invariants (do not break)

- `~/Projects/dotfiles` is the single source of truth: home paths are symlinks; edit in the repo, then commit and push.
- Ghostty is a thin front end. tmux owns panes/splits; never add Ghostty/AppleScript splits.
- `cmd` never reaches the terminal. GUI shortcuts are bridged: Ghostty keybind sends `Alt+<key>` (`text:\x1b...`), tmux forwards it, Neovim maps `<A-...>`.
- The editor layout is pinned deterministically: `candela-workspace` `build_prs` creates it and `normalize_editor` re-applies gh-dash = 76 cols, bottom row = 14 lines (on `ensure`, restore, and window resize). Change sizes only there.
- `candela-workspace` owns the workspace: `open`, `ensure`, `review`, `post-restore`, `normalize-editor`.
- tmux-resurrect restores panes but not pane options or pinned sizes, so `normalize_editor` re-applies sizes and re-tags the nvim pane (`@candela_review_pane`).
- Neovim: NvChad v2.5, leader = space; octo.nvim reviews, gh-dash triages.
- Palette stays consistent: Ghostty monokai palette, tmux-nova `#2a2a2a` borders, nvim theme `ghostty`.
- Never commit secrets. `.zshrc`'s `CANDELA_UI_READ_TOKEN` is fetched at runtime; `mcp.json`'s GitHub token is `!gh auth token`.

## Configuration map (dotfiles path -> what it configures)

| Path | Configures |
| --- | --- |
| `.config/ghostty/config` | Ghostty theme, cursor, tmux keybinds, cmd->Alt bridges, window cycling |
| `.tmux.conf` | status/nova, tpm plugins, mouse, titles, cursor, extended-keys, C-w, resize hook |
| `.local/bin/candela-workspace` | sessions, layout, open/reuse, review helper, normalize/restore |
| `.config/nvim/**` | NvChad config, mappings, cursor, octo, nvim-tree, theme |
| `.config/gh-dash/config.yml` | Candela PR sections, repoPaths, keybindings (`enter`, `o`) |
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
| Neovim | restart nvim, `:Lazy` | `:checkhealth octo` (after `:Octo` loads) |
| gh-dash | relaunch `gh dash` (config read at launch) | gh-dash schema |
| candela-workspace | `bash -n`, `candela-workspace ensure` | `candela-workspace normalize-editor` |
| skhd | `skhd --reload` | `/tmp/skhd_joelove.{out,err}.log` |
| yabai | `yabai --restart-service` | `.automations.sh` helpers |
| gh | - | `gh auth status` |

## Known pitfalls

- A shell variable named `TMUX` shadows tmux's socket env; `candela-workspace` uses `TMUX_BIN`.
- `extended-keys` / `terminal-features` changes only take effect on a new client attach (restart/re-attach tmux).
- resurrect restores the saved (often old) layout and drops pane options; `normalize_editor` is what fixes it.
- Ghostty `text:` keybinds use Zig escapes (single backslash) and comments must be on their own lines.
- Neovim cannot see `cmd`; bridge every GUI shortcut via Ghostty -> `Alt`.
- octo is lazy (`cmd = "Octo"`), so `:checkhealth octo` needs it loaded first.
- gh-dash reads config at launch; `o` overrides its built-in open-in-browser.
- The editor pane opens `~/Projects/candela` (not a git repo), so octo needs explicit repo/URL.

## How to change safely

1. Edit the file in `~/Projects/dotfiles`, never the symlink target directly.
2. Validate with the tool's check from the table above.
3. Reload/restart the tool and confirm the behaviour.
4. Commit and push `~/Projects/dotfiles`.
5. Keep coupled changes together: a new shortcut needs both the Ghostty bridge and the nvim `<A-...>` map; a layout size needs both `build_prs` and `normalize_editor`.

## Related skills

- `github-prs` (PR create + open review), `review-code`, `autopilot`, `create-skill`, `shell-context`.
