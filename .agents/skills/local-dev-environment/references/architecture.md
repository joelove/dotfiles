# Local dev environment: architecture and configuration

Exhaustive per-tool detail. `SKILL.md` has the invariants and the quick map;
this file is the reference for changing or debugging anything.

## Sessions and profiles (`dev-workspace`)

- Engine: `~/Projects/dotfiles/.local/bin/dev-workspace`, symlinked to
  `~/.local/bin/dev-workspace`. It sets its own `PATH`, uses a `TMUX_BIN`
  variable (never `TMUX`), guards tmux queries with no server, and computes
  `DEV_SELF` from `BASH_SOURCE` so Ghostty windows can re-invoke it.
- Invocation: `dev-workspace [<profile>] <cmd>`. A leading known subcommand
  selects the default `projects` profile; otherwise the first argument is the
  profile name. Profiles are sourced bash at `~/.config/dev-workspace/<name>.conf`.
- Profile fields and defaults: `DEV_NAME` (basename of root, lowercased),
  `DEV_ROOT` (`~/Projects`), `DEV_AGENT_DIR` (root), `DEV_AGENT_CMD` (`pi`; empty
  skips the agent session), `DEV_AGENT_PANES` (2), `DEV_AGENT_SESSION`
  (`${DEV_NAME}-agent`), `DEV_EDITOR_DIR` (root), `DEV_EDITOR_CMD` (`croft`),
  `DEV_EDITOR_SESSION` (`${DEV_NAME}-editor`), `DEV_REVIEW_CMD` (`gh dash`;
  empty omits the pane), `DEV_REVIEW_SUB_CMD` (empty omits the pane; e.g. a live
  actions readout) with `DEV_REVIEW_SUB_LINES` (5; the pane's baseline height,
  which a self-sizing sub-command can override), `DEV_TERM_DIRS` (one pane at
  root; relative paths resolve against root), `DEV_TERM_CMDS` (commands parallel
  to `DEV_TERM_DIRS`; empty entries leave a plain shell, default all empty),
  `DEV_GH_COLS` (76), `DEV_BOTTOM_LINES` (14).
- A workspace is two sessions in two Ghostty windows: the agent view
  (`DEV_AGENT_SESSION`, `DEV_AGENT_PANES` panes running `DEV_AGENT_CMD`) and the
  editor view (`DEV_EDITOR_SESSION`: editor pane, optional review pane with an
  optional `DEV_REVIEW_SUB_CMD` pane stacked directly below it, bottom row of
  `DEV_TERM_DIRS`). Window names are `agent` / `editor`.
- Commands: `open` (default), `build`, `ensure`, `attach [session]`,
  `attach-only [session]`, `review-pane` (idempotently relaunch the review
  command in its pane), `normalize-editor [--all]`, `post-restore [--all]`,
  `list`, `print-config`.
- `open`: `ensure`, then focus if all sessions have clients, else create only
  the missing Ghostty windows in one instance (fresh launch uses
  `--initial-window=false`; window command is `dev-workspace <profile>
  attach-only <session>`). `focus_workspace_windows` matches yabai windows by
  session-name title (`set-titles-string '#S'`) and swaps each display's space.
- `ensure`: restore the newest tmux-resurrect save when a session is missing,
  `build`, `normalize-editor`. Per-profile lock dir
  `/tmp/dev-workspace-<name>.lock`.
- `normalize_editor`: geometry-based. Top row: leftmost pane is the editor,
  rightmost is the review
  pane resized to `DEV_GH_COLS` when present; the pane directly below the review
  pane (same left, next top) is resized to `DEV_REVIEW_SUB_LINES`. Bottom row:
  leftmost pane resized to `DEV_BOTTOM_LINES`. `--all` iterates every profile
  plus the default and is debounced 0.25s for the resize hook.
- `start_agent_in_shells` / `start_views_in_shells`: after a restore, start
  `DEV_AGENT_CMD` in agent panes and the editor/review commands in the editor
  panes, but only where they are sitting at a plain shell (marked with
  `@dev_agent_started` for the agent). resurrect cannot restore a command with
  arguments, which is why the review pane is started this way. It also
  restarts the `DEV_REVIEW_SUB_CMD` pane below the review pane and any non-empty
  `DEV_TERM_CMDS` in the bottom row, left to right; pane options
  (`@dev_review_sub_started`, `@dev_term_started`) stop a second restart.
- A project wrapper is one line: `exec dev-workspace <profile> "$@"`. Profiles
  can pin session names (e.g. to preserve an existing resurrect save), point
  `DEV_REVIEW_CMD` at a project-specific `gh dash --config` kept under
  `.config/dev-workspace/`, optionally stack a `DEV_REVIEW_SUB_CMD` below the
  review pane, and list the project's terminal subdirs in `DEV_TERM_DIRS`.

## Ghostty

- Repo path: `~/Projects/dotfiles/.config/ghostty/config`, symlinked to
  `~/.config/ghostty` (directory symlink).
- Font: MesloLGS NF 15, `adjust-cell-height = 28%`.
- Colors: black background, `#f8f8f2` foreground, monokai ANSI palette, cursor
  `#ffa827`, selection `#403d3d`.
- `cursor-style = block`; Ghostty renders a hollow block when the surface is
  unfocused (built-in renderer behaviour, not a setting).
- `unfocused-split-opacity = 0.85`, `split-divider-color = #2a2a2a`.
- `shell-integration-features = no-cursor,no-sudo,title,no-ssh-env,no-ssh-terminfo,path`.
- `ctrl+tab` / `ctrl+shift+tab` cycle Ghostty windows (not tabs).
- croft's Cmd chords: `croft setup-ghostty` appends a marker-fenced managed
  `keybind` block (re-run it to update; do not hand-edit inside) that re-emits
  croft's chords as CSI-u. The colliding pane chords are the exception: Ghostty
  sends them as `text:` `C-b C-v <slot>` and tmux's `croft` key table decides
  (see tmux below), so their lines are removed from the managed block. `super+n`
  is forwarded too (croft's new untitled tab). Re-running `croft setup-ghostty`
  re-adds the pane chords as CSI-u; remove those eight lines again.
- Reload: `cmd+shift+,` or restart. Validate: `ghostty +validate-config`;
  inspect `ghostty +list-keybinds`.

## tmux

- Repo path: `~/Projects/dotfiles/.tmux.conf`, symlinked to `~/.tmux.conf`.
- Status on top (`status-position top`), tmux-nova with `mode` + `time`
  segments; pane label `#I ... #W`. Borders are `#2a2a2a` for both active and
  inactive (no green highlight).
- Plugins via tpm: tmux-resurrect, tmux-continuum, tmux-nova.
- resurrect: `capture-pane-contents on`; `continuum-restore off`
  (dev-workspace drives restore); no `@resurrect-processes` entries (croft and
  the review command have arguments resurrect cannot restore); the post-restore
  hook runs `/Users/joelove/.local/bin/dev-workspace post-restore --all`, which
  starts the agent and the per-profile editor/review commands from their shells.
- `default-shell /bin/zsh`.
- terminal-features: `*:RGB` (truecolor), `xterm*:extkeys` (modified keys like
  Shift+Enter), `xterm*:hyperlinks` (OSC 8).
- `mouse on` (click to focus, scroll, border drag). `MouseDown1Pane` is
  overridden: a plain left click on an OSC 8 hyperlink whose URL contains
  `actions/runs` opens it with `/usr/bin/open` (tmux resolves the link via
  `#{mouse_hyperlink}`); any other click keeps the default focus-and-forward
  behaviour. This is what makes the running-actions rows clickable without
  relying on Ghostty's Cmd+click.
- `set-titles on` + `set-titles-string '#S'` (unique session name; used by
  dev-workspace to find each Ghostty window).
- `cursor-style blinking-block` (focused pane flashes; Ghostty hollows the
  unfocused window).
- `extended-keys on` with `extended-keys-format csi-u` (carries croft's
  Ghostty-forwarded Cmd chords through tmux).
- `croft` key table: `C-b C-v` enters it (Ghostty sends that for the colliding
  chords). The pane slots `d/D/w/e/h/l/k/j` `if-shell`-check
  `pane_current_command=croft`: when croft is focused they re-inject the raw
  CSI-u with `send-keys -H` so croft wins the chord, otherwise they run the
  iTerm-like pane action (`Cmd+D` and `Cmd+Shift+D` split, `Cmd+W` kill,
  `Cmd+Shift+Enter` zoom, `Cmd+Alt+arrows` focus). The slots `1-8/b/f` inject
  the raw chord unconditionally for the non-pane colliding Cmd chords
  (`Cmd+Left/Right/Up/Down`, `Cmd+Shift+Left/Right/Up/Down`,
  `Cmd+Backspace/Delete`). A key table, not a global `M-` binding, so genuine
  Alt chords are untouched.
- Prefix is default `C-b`. `prefix r` sources the config. `C-w` is the default
  `kill-pane`; croft closes its own editor tab with `Cmd+W` (a croft chord, not
  a tmux one).
- `set-hook -g window-resized` runs
  `dev-workspace normalize-editor --all` (debounced).
- Inspect: `tmux show-options -g`, `tmux show-hooks -g`,
  `tmux list-keys -T prefix`.

## croft

- Repo path: `~/Projects/dotfiles/.config/croft/`, symlinked to `~/.config/croft`
  (directory symlink).
- Built from a local `~/Projects/croft` checkout of git main into
  `~/.cargo/bin/croft` (the `vitali87/croft` Homebrew tap no longer exists and
  releases ship no binaries; crates.io is 0.1.942 and hardcodes chrome). The
  checkout carries `.config/croft/patches/tmux-monokai.patch`; after `git pull`,
  re-apply it and run `cargo install --path . --locked`.
- Launch: the editor pane runs `croft` with its cwd at `DEV_EDITOR_DIR`, so it
  opens that folder. `croft <file>` opens a file; `croft pr <n>` opens a native
  PR review tab; `croft edit --wait` opens a file in the croft hosting the pane
  (what `EDITOR`/`GIT_EDITOR` use).
- Config: `config.json` in the same directory; `theme: "monokai-terminal"`,
  `format_on_save: true`, `suppress_terminal_warning: true`. Keep it **strict
  JSON**: 0.1.942 loaded defaults when the file had `//` comments (despite the
  docs), and croft rewrites it expanded on any UI toggle.
- Theme: `extensions/monokai-terminal/extension.toml` is a user `[[themes]]`
  manifest with `gradient = true` and monokai chrome fields. croft has **no
  ANSI-passthrough mode**, so the patch snaps its brand chrome through
  `rgb_color()` to the nearest of the 16 Ghostty/iTerm monokai ANSI indices,
  which the terminal renders from its own palette; the editor frame, gutter,
  activity pill and inner accents become terminal-numbered colours instead of
  truecolor. The `ansi` array equals the Ghostty `palette =` lines. If the
  Ghostty palette changes, update both.
- Settings: croft's bottom panel is patched to start hidden (`show_terminal:
  false` in `App::new`); `Ctrl+J` toggles it and `Cmd+B` the primary side bar
  (croft does not persist either across launches). `Cmd+,` opens the settings
  hub via the tracked `keybindings.json`, forwarded by a `super+,` Ghostty
  keybind (Ghostty's default there opens its own config).
- LSP: croft provisions its own servers on first use (vtsls,
  yaml-language-server, json/html/css, bash, ty/ruff) into `~/.croft/servers`,
  and uses `rust-analyzer`/`taplo`/`clangd` from PATH when present.
- Vim mode is a per-session toggle on `Cmd+E` (not config-persisted).
- Cmd chords reach croft via the managed Ghostty block (see Ghostty above); tmux
  `extended-keys` carries the CSI-u sequences. tmux has no Super modifier and
  maps the CSI-u super bit onto Meta, so inside tmux most Cmd chords arrive as
  Alt; the patch promotes Alt back to Super in `App::handle_key` on macOS
  (guarded by `$TMUX`). The colliding pane chords skip that path: the `croft`
  key table re-injects their raw CSI-u when croft is focused (see tmux above).
  tmux cannot tell Cmd from Alt apart, so croft's genuine Alt chords fold onto
  their Cmd counterparts.
- `keybindings.json` binds `Cmd+,` to `open_settings`, `Cmd+N` to the patched
  `new_file` command (a new untitled tab), and `Cmd+T` to `quick_open` (Go to
  File), overriding croft's new-terminal binding.
- Sublime/Atom parity: the patch adds `cursor_*`, `select_word`, `delete_*` and
  `expand_selection_to_line` commands; `keybindings.json` binds line and word
  move/select, `Ctrl+Shift+A/E/W`, `Cmd+Up/Down` (+Shift), and
  `Alt+Backspace/Delete` / `Cmd+Backspace/Delete`. Because tmux collapses Cmd
  onto Alt, the colliding Cmd chords go through the `croft` key table and
  `App::handle_key` skips the Alt-to-Super promotion for the Alt chords croft
  owns (`alt_is_croft_chord`), so both meanings survive.
- focus-editor-group moved from `Cmd+Alt+Left/Right` to `Cmd+K Cmd+Left/Right`.
- Borderless, tabless chrome: the fork removes the box borders around the
  sidebar, editor, and welcome pane, the sidebar `EXPLORER` title (and its `⋯`
  views button), and the editor tab strip, so those rows and columns are
  content. Files are switched with Go to File; `Cmd+T` is rebound to it. View
  toggles stay in the command palette and settings.
- croft runs inside tmux, which blocks its inline-image protocol, so it uses
  the image-less fallback: activity-bar/file icons render as Nerd Font glyphs
  and previews as a metadata line. `suppress_terminal_warning: true` silences
  the startup "switch terminal" nudge.

## gh-dash

- Repo path: `~/Projects/dotfiles/.config/gh-dash/`, symlinked to
  `~/.config/gh-dash`.
- `config.yml` is the default profile: `prSections` lists all open PRs for
  `user:joelove`; `repoPaths` maps local checkouts.
- A project profile can keep its own gh-dash config in
  `.config/dev-workspace/<name>.yml` and set
  `DEV_REVIEW_CMD="gh dash --config ~/.config/dev-workspace/<name>.yml"`.
- Both configs use gh-dash's stock keys (`o` opens the PR in the browser), with
  the same `defaults` and preview settings; the old `o`-to-nvim diff binding is
  gone with octo.nvim.
- Both configs set `theme.ui` to `sectionsShowCount: false` and
  `table.compact/showSeparator: false` for a denser list. gh-dash's own section
  title and separator header cannot be hidden (no config for it).
- gh-dash reads its config at launch; each workspace runs its own
  `gh dash --config ...` so the review pane shows the right sections.
- gh-dash has no Actions/workflow-runs view or section (v4.26), and the
  `status:pending` PR qualifier matches PRs whose head commit has no checks, not
  PRs with running checks. To watch running Actions, a project profile runs
  `.local/bin/running-actions` directly below the gh-dash pane via
  `DEV_REVIEW_SUB_CMD`. It queries the REST `/actions/runs` endpoint per repo
  with `gh api --cache` (default 60s) on a 30s poll loop, keeps only the newest
  run per workflow, and shows live (queued/in-progress) runs with a live
  `mm:ss`/`h:mm:ss` duration that redraws every second plus any run that
  finished within `RUNNING_ACTIONS_RECENT` (15 min). The dot is yellow while
  live, green on success, red on failure, and dim for other conclusions. Live
  rows are listed first, and the pane resizes itself to one line per row
  (clamped to 8, and effectively hidden at a single empty line when zero), so it
  and gh-dash share the right column dynamically. Each row is an OSC 8 hyperlink
  to the run, so Cmd+click opens it in the browser (via tmux's
  `xterm*:hyperlinks` and Ghostty's default link handling); a plain left click
  also opens it through the tmux `MouseDown1Pane` binding above.

## pi

- `~/.pi/agent/settings.json`: theme `monokai`, `shellPath /bin/zsh`, default
  provider openrouter, `deepseek/deepseek-v4.1-flash` with high thinking,
  `tuiMode fullscreen`, cursor shown, packages `pi-mcp-adapter` and
  `@janvitos/pi-plan-build`.
- `~/.pi/agent/mcp.json`: `linear` (hosted MCP) and `github` (bearer token from
  `!gh auth token`).
- `~/.pi/agent/agents/`: `reviewer.md`, `security-reviewer.md`.
- `~/.pi/agent/extensions/`: `native-cursor.ts`, `subagent/`.
- `~/.pi/agent/keybindings.json`: interrupt on escape/ctrl+c.
- `~/.pi/agent/themes/monokai.json`.
- Skills: `~/.pi/agent/skills/<name>` are symlinks into `~/.agents/skills/<name>`
  (the shared skills dir). Skill sources for this environment live in
  `~/Projects/dotfiles/.agents/skills/`.

## zsh and git

- `.zshrc` (symlinked): oh-my-zsh + powerlevel10k, nvm/zoxide/fzf/pyenv, PATH
  additions, `EDITOR`/`GIT_EDITOR`/`GIT_SEQUENCE_EDITOR` = `croft edit --wait`,
  aliases `v`/`vim`/`code`/`c` -> croft, `cat` -> bat, git aliases, `pr`
  helper.
- `.zprofile`, `.zshenv` (sources `.automations.sh`), `.p10k.zsh`.
- `.gitconfig`: identity plus `gh auth git-credential` helpers for github.com
  and gist.github.com.

## skhd and yabai

- `.skhdrc` (symlinked): `cmd+alt+tab` runs the workspace wrapper's `open`
  (`<project>-workspace open` / `dev-workspace <profile> open`);
  `cmd+alt+shift+arrows` -> yabai spatial focus (window, else display); window
  sizing hotkeys (`ctrl+alt+cmd`/`ctrl+cmd+shift` + space/x/c/z/tilde); move
  window across displays; `hyper+1..4` app launches; `cmd+esc` dual-mac
  passthrough.
- `.automations.sh` (sourced from `.zshenv`): yabai grid sizing helpers,
  display/space focus helpers, and the `prs()` alias for `gh dash`.
- `.yabairc`: loads the yabai scripting addition, dock-restart signal,
  minimized-window focus signal.
- Reload skhd with `skhd --reload` (logs in `/tmp/skhd_joelove.{out,err}.log`);
  restart yabai with `yabai --restart-service`.

## karabiner and QMK

- `.config/karabiner/karabiner.json` plus `assets/complex_modifications/*.json`
  (stored in dotfiles; Karabiner manages the live file).
- `qmk/` holds Sofle/Unhand keymaps and hex files; `hyper` is defined on the
  keyboard.

## This week's configuration (dotfiles commits)

- 2026-09-21 `2989f60` import the Ghostty, Neovim and workspace configs;
  symlink Ghostty, nvim, gh-dash and the workspace launcher.
- 2026-09-23 `f4345b0` octo.nvim + open-PR-for-review integration (review
  subcommand, gh-dash binding, github-prs skill, gh-dash config in dotfiles).
- 2026-09-23 `0d65df3` gh-dash `o` bound to review-in-nvim.
- 2026-09-23 `9c84d0d` workspace TMUX_BIN fix.
- 2026-09-23 `33d34c4` tolerant `review_pane`.
- 2026-09-23 `669a25c`, `55161d7`, `f6996d7`, `d91d7a1`: fixed editor sizes,
  later re-pinned by `normalize_editor`.
- 2026-09-23 `f50ae50` normalize on ensure/restore; `4c65d9b` `window-resized`
  hook.
- Generic `dev-workspace` engine + per-project profiles, one-line project
  wrappers, per-profile gh-dash configs (default all `user:joelove`, per-project
  configs under `.config/dev-workspace/`), `set-titles-string #S`, and
  `dev-workspace ... --all` hooks.
- Latest: replaced Neovim with croft (editor pane, `croft setup-ghostty` Cmd
  chords, exact-match `monokai-terminal` theme, format-on-save), removed the
  nvim config and the Ghostty/tmux/gh-dash/octo integrations, and moved shell
  editing to `croft edit --wait`.

## Debugging playbook

- Layout wrong after restart or resize: `dev-workspace [<profile>]
  normalize-editor` (or `ensure`); check
  `tmux list-panes -t <session> -F '#{pane_id} #{pane_width} #{pane_height}'`.
- `dev-workspace` acts on the wrong server: a `TMUX` variable is shadowing the
  socket env; check the engine uses `TMUX_BIN`.
- Modified keys (Shift+Enter) not working: `extended-keys`/`extkeys` need a
  fresh client attach; restart tmux or re-attach.
- croft Cmd shortcut does nothing: verify the managed Ghostty block
  (`ghostty +list-keybinds`, `grep 'croft keybindings'`), then run `croft keys`
  in the editor pane to see whether the CSI-u sequence reaches croft through
  tmux (`extended-keys` must be on with `csi-u`).
- Ghostty keybind sends garbage: check for inline comments or a doubled
  backslash in `text:` escapes, and that the croft managed block is intact.
- Theme looks wrong: croft has no ANSI passthrough; confirm the
  `monokai-terminal` manifest's `ansi` array equals the Ghostty `palette =`
  lines and that `~/.config/croft` is the repo symlink.
- resurrect brought back old panes/options: expected; `normalize_editor`
  re-applies sizes.
- tmux config parse errors: `tmux source-file ~/.tmux.conf` and read stderr;
  `tmux show-options -g` / `show-hooks -g` to confirm what applied.

## Improving safely

- Add a croft shortcut in `~/.config/croft/keybindings.json`, then re-run
  `croft setup-ghostty` so the Cmd chord is forwarded; reload Ghostty and croft.
- Change editor sizes as profile fields (`DEV_GH_COLS`, `DEV_BOTTOM_LINES`,
  `DEV_REVIEW_SUB_LINES`); `normalize_editor` consumes them.
- Add a pane below the review pane as `DEV_REVIEW_SUB_CMD`, or a bottom-strip
  command as the matching `DEV_TERM_CMDS` entry (parallel to `DEV_TERM_DIRS`),
  not engine code; empty values omit/keep plain shells.
- Add a project as a profile in `~/.config/dev-workspace/<name>.conf` plus a
  one-line wrapper in `.local/bin/<name>-workspace`; do not fork the engine.
- Keep tmux as the only pane owner; do not introduce Ghostty splits.
- Keep the palette consistent with the existing monokai values, and mirror any
  Ghostty palette change into the croft `monokai-terminal` `ansi` array.
- Validate before committing: `ghostty +validate-config`,
  `tmux source-file`, `bash -n dev-workspace`, `croft --version`.
- Commit and push `~/Projects/dotfiles`; home config is a symlink, so an
  uncommitted edit is easy to lose.
