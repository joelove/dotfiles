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
| `.config/ghostty/config` | Ghostty theme, cursor, croft's managed Cmd block, the `C-b C-v` pane/Sublime forwards |
| `.tmux.conf` | status/nova, tpm plugins, mouse, titles, cursor, extended-keys, hooks |
| `.config/gh-dash/config.yml` | gh-dash default profile (all `user:joelove` PRs) |
| `.config/croft/config.json` | croft settings (exact-match `monokai-terminal` theme, format-on-save) |
| `.config/croft/extensions/monokai-terminal/**` | user `[[themes]]` manifest equal to the Ghostty palette |
| `.config/croft/keybindings.json` | croft chords: settings, `new_file`, Go to File, and the Sublime/Atom move/select/delete set |
| `.agents/skills/*/SKILL.md` | agent skills |
| `.skhdrc` / `.automations.sh` / `.yabairc` | hotkeys, yabai sizing/space helpers, signals |
| `.zshrc` / `.zprofile` / `.zshenv` / `.p10k.zsh` | shell, aliases (`v`/`vim`/`code`/`c` -> croft), workspace launchers (`ws`/`cws`), PATH, `EDITOR`/`GIT_EDITOR` (`croft edit --wait`) |
| `.gitconfig` | git identity + gh credential helper |
| `.config/karabiner/`, `qmk/` | keyboard remaps and QMK keymaps |

pi config is tracked in dotfiles at
`.pi/agent/{settings.json,mcp.json,AGENTS.md,agents,extensions,themes,skills}`
and symlinked into `~/.pi/agent` by `setup-pi.sh`; runtime state (`auth.json`,
`sessions/`, `npm/`, `plans/`, caches) stays in the real `~/.pi/agent` and is
gitignored. Skills are discovered from `~/.agents/skills`. The patched croft
source lives outside dotfiles: `~/Projects/croft` (`origin` = `joelove/croft`,
branch `personal`; `upstream` = `vitali87/croft`).

## Reload / debug

| Tool | Reload | Inspect |
| --- | --- | --- |
| Ghostty | `cmd+shift+,` or restart | `ghostty +validate-config`, `+list-keybinds` |
| tmux | `prefix r` or `tmux source-file ~/.tmux.conf`; `prefix R` (or `Cmd+Ctrl+R` in Ghostty) resets the current dev-workspace | `tmux show-options -g`, `show-hooks -g`, `list-keys -T prefix` |
| dev-workspace | `bash -n`, `dev-workspace <profile> print-config`; `dev-workspace restart --session NAME` (bound to `prefix R` / `Cmd+Ctrl+R`) | `dev-workspace [<profile>] ensure`, `normalize-editor` |
| croft | restart croft; rebuild from `~/Projects/croft` (`cargo install --path . --locked`) | `croft keys`, theme picker, `croft --version` |
| gh-dash | relaunch `gh dash` (config read at launch) | gh-dash schema |
| skhd | `skhd --reload` | `/tmp/skhd_joelove.{out,err}.log` |
| yabai | `yabai --restart-service` | `.automations.sh` helpers |
| gh | - | `gh auth status` |

## Known pitfalls

- A shell variable named `TMUX` shadows tmux's socket env; `dev-workspace` uses
  `TMUX_BIN`.
- `prefix R` (or `Cmd+Ctrl+R` in Ghostty) resets the workspace whose agent or
  editor session the invoking pane belongs to. It rebuilds each session in
  place: the new layout is built under a temporary name, the attached tmux
  client is moved across, then the names are swapped, so the same Ghostty window
  keeps showing the workspace instead of stranding a "session ended" window and
  opening a fresh one. The rebuild uses the profile's default layout, not the
  resurrect save, so gh-dash/review and every bottom shell come back even when
  the save is stale. That restarts croft, the agents and the shells (losing
  their state); add `--editor-only` to spare the agent session, or use
  `prefix r` for a config-only reload. The binding runs the script with
  `run-shell -b` so it survives its own session teardown.
- `extended-keys` / `terminal-features` changes only take effect on a new client
  attach (restart or re-attach tmux).
- resurrect restores the saved (often old) layout and drops pane options;
  `normalize_editor` is what fixes it.
- croft's managed Ghostty block uses `csi:` actions; re-run `croft setup-ghostty`
  to update it, never hand-edit between the marker comments. That re-run also
  re-adds the pane chords (`cmd+d`, `cmd+shift+d`, `cmd+w`, `cmd+shift+enter`,
  `cmd+alt+arrow_*`) and the colliding Sublime/Atom Cmd chords (`cmd+left`,
  `cmd+right`, `cmd+up`, `cmd+down`, `cmd+shift+left/right/up/down`,
  `cmd+backspace`, `cmd+delete`) as CSI-u, which would win over the Ghostty
  `C-b C-v` sequences; remove them again after a re-run.
- croft cannot inherit the host terminal's ANSI palette (themes are RGB hex);
  mirror Ghostty `palette =` changes into the `monokai-terminal` `ansi` array.
- croft saves `config.json` by renaming a temp file over it, so track the config
  **directory** (`~/.config/croft` is a symlink); a file symlink would be
  clobbered.
- croft's Cmd chords need the `croft setup-ghostty` managed Ghostty block plus
  tmux `extended-keys on` with `csi-u`; verify with `croft keys` in the pane.
- Ctrl+Tab / Ctrl+Shift+Tab cycle the dev-workspace swap pane, routed through
  tmux's `croft` key table (Ghostty sends prefix + C-v + `p` / `P`; see
  `.tmux.conf` and `.config/ghostty/config`), because a bare `csi:` sequence from
  Ghostty does NOT survive the tmux hop. Croft's Go to Tab is now Ctrl+Alt+Tab /
  Ctrl+Alt+Shift+Tab (slots `a` / `A`). `croft setup-ghostty` does NOT emit these
  (it only forwards Cmd chords), so those Ghostty lines survive a re-run, but
  re-sourcing `.tmux.conf` installs the `p` / `P` and `a` / `A` binds.
- The swap pane keeps croft, lumen and mdcat alive: the non-visible modes sit in
  a detached `_pool` window (`DEV_SWAP_POOL_WINDOW`) and `tmux swap-pane` moves
  them into the editor window's top-left slot. resurrect drops pane options, so
  `rebuild_swap` reruns after a restore; a dead pool pane is respawned from its
  `@dev_swap_cmd`.
- `CROFT_VIEW_SOCK` is published per tmux session, so it only resolves inside
  the editor session that hosts croft; the agent session next door has no croft
  to reach.
- gh-dash reads config at launch; `o` opens the browser and `l` runs
  `dev-workspace open-review` to load the selected PR into the lumen swap tab.
- lumen is the `joelove/lumen` fork (branch `personal`): upstream has no ANSI
  theme, so the fork adds `ansi` / `Theme::ansi()` (16 slots). Rebuild with
  `cargo install --path ~/Projects/lumen --locked`. mdcat is Homebrew's
  `BIRSAx2/mdcat` fork; `mdpick`/`mdless` are `exec -a` argv[0] wrappers.
  The review tab defaults to `repo-review <config>`, an fzf picker over that
  profile's gh-dash `repoPaths`; the docs tab loops `mdpick` so quitting mdcat
  returns to the picker.
- `.zshenv` exports a UTF-8 locale (`LANG`/`LC_CTYPE=en_US.UTF-8`) and
  `.tmux.conf` seeds the same in tmux's global env. macOS/launchd and Ghostty
  leave the locale unset, and without it `less` (the pager mdcat's `mdpick` and
  `mdless` use) renders multibyte glyphs as `<XX>` instead of box drawing.
- croft's `config.json` must be strict JSON; a `//` comment made 0.1.942 fall
  back to defaults. croft rewrites the file expanded on any UI toggle.
- tmux has no Super: it maps the Cmd (CSI-u super) bit to Meta, so croft sees
  Alt under tmux. The `joelove/croft` fork (branch `personal`) promotes Alt back
  to Super on macOS (guarded by `$TMUX`) while leaving the Alt chords croft owns
  alone. Rebuild with `cargo install --path ~/Projects/croft --locked` after
  fetching upstream.
