# Local dev environment: configuration map, reload, pitfalls

## Configuration map (dotfiles path -> what it configures)

| Path | Configures |
| --- | --- |
| `.local/bin/dev-workspace` | generic workspace engine (sessions, layout, Ghostty windows, review helper) |
| `.local/bin/running-actions` | live in-progress Actions view for a dev-workspace bottom pane |
| `.local/bin/audit-agent-context.mjs` | read-only report of advertised pi skills and context bytes |
| `.local/bin/*-workspace` | per-project one-line wrappers over a profile |
| `.config/dev-workspace/*.conf` | per-project profiles |
| `.config/dev-workspace/*.yml` | per-project gh-dash configs |
| `.config/ghostty/config` | Ghostty theme, cursor, tmux keybinds, cmd-to-Alt bridges |
| `.tmux.conf` | status/nova, tpm plugins, mouse, titles, cursor, extended-keys, hooks |
| `.config/gh-dash/config.yml` | gh-dash default profile (all `user:joelove` PRs) |
| `.config/nvim/**` | NvChad config, mappings, cursor, octo, nvim-tree, theme |
| `.agents/skills/*/SKILL.md` | agent skills |
| `.skhdrc` / `.automations.sh` / `.yabairc` | hotkeys, yabai sizing/space helpers, signals |
| `.zshrc` / `.zprofile` / `.zshenv` / `.p10k.zsh` | shell, aliases (`v`/`code`/`c` -> nvim), PATH, EDITOR |
| `.gitconfig` | git identity + gh credential helper |
| `.config/karabiner/`, `qmk/` | keyboard remaps and QMK keymaps |

pi lives outside dotfiles: `~/.pi/agent/{settings.json,mcp.json,agents,extensions,themes}`;
skills are discovered from `~/.agents/skills`.

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

- A shell variable named `TMUX` shadows tmux's socket env; `dev-workspace` uses
  `TMUX_BIN`.
- `extended-keys` / `terminal-features` changes only take effect on a new client
  attach (restart or re-attach tmux).
- resurrect restores the saved (often old) layout and drops pane options;
  `normalize_editor` is what fixes it.
- Ghostty `text:` keybinds use Zig escapes (single backslash) and comments must
  be on their own lines.
- Neovim cannot see `cmd`; bridge every GUI shortcut via Ghostty to `Alt`.
- octo is lazy (`cmd = "Octo"`), so `:checkhealth octo` needs it loaded first.
- gh-dash reads config at launch; `o` overrides its built-in open-in-browser.
- The editor pane's cwd is a project root that may not be a git repo; octo needs
  an explicit repo or URL.
