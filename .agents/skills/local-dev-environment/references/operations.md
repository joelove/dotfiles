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
| `.config/ghostty/config` | Ghostty theme, cursor, croft's managed Cmd-chord block |
| `.tmux.conf` | status/nova, tpm plugins, mouse, titles, cursor, extended-keys, hooks |
| `.config/gh-dash/config.yml` | gh-dash default profile (all `user:joelove` PRs) |
| `.config/croft/config.json` | croft settings (exact-match `monokai-terminal` theme, format-on-save) |
| `.config/croft/extensions/monokai-terminal/**` | user `[[themes]]` manifest equal to the Ghostty palette |
| `.agents/skills/*/SKILL.md` | agent skills |
| `.skhdrc` / `.automations.sh` / `.yabairc` | hotkeys, yabai sizing/space helpers, signals |
| `.zshrc` / `.zprofile` / `.zshenv` / `.p10k.zsh` | shell, aliases (`v`/`vim`/`code`/`c` -> croft), PATH, `EDITOR`/`GIT_EDITOR` (`croft edit --wait`) |
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
| croft | restart croft (settings hot-reload; layout/scrollback need a relaunch) | `croft keys`, theme picker, `croft --version` |
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
- croft's managed Ghostty block uses `csi:` actions; re-run `croft setup-ghostty`
  to update it, never hand-edit between the marker comments. That re-run also
  re-adds the pane chords (`cmd+d`, `cmd+shift+d`, `cmd+w`, `cmd+shift+enter`,
  `cmd+alt+arrow_*`), which are removed so the `text:` tmux controls win
  (Ghostty is last-wins); remove them again after a re-run.
- croft cannot inherit the host terminal's ANSI palette (themes are RGB hex);
  mirror Ghostty `palette =` changes into the `monokai-terminal` `ansi` array.
- croft saves `config.json` by renaming a temp file over it, so track the config
  **directory** (`~/.config/croft` is a symlink); a file symlink would be
  clobbered.
- croft's Cmd chords need the `croft setup-ghostty` managed Ghostty block plus
  tmux `extended-keys on` with `csi-u`; verify with `croft keys` in the pane.
- gh-dash reads config at launch; its keys are stock (`o` opens the browser).
- croft's `config.json` must be strict JSON; a `//` comment made 0.1.942 fall
  back to defaults. croft rewrites the file expanded on any UI toggle.
