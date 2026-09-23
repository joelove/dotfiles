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
  (`${DEV_NAME}-agent`), `DEV_EDITOR_DIR` (root), `DEV_EDITOR_CMD` (`nvim .`),
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
  `attach-only [session]`, `review <pr>`, `review-pane` (idempotently relaunch
  the review command in its pane), `normalize-editor [--all]`,
  `post-restore [--all]`, `list`, `print-config`.
- `open`: `ensure`, then focus if all sessions have clients, else create only
  the missing Ghostty windows in one instance (fresh launch uses
  `--initial-window=false`; window command is `dev-workspace <profile>
  attach-only <session>`). `focus_workspace_windows` matches yabai windows by
  session-name title (`set-titles-string '#S'`) and swaps each display's space.
- `ensure`: restore the newest tmux-resurrect save when a session is missing,
  `build`, `normalize-editor`. Per-profile lock dir
  `/tmp/dev-workspace-<name>.lock`.
- `normalize_editor`: geometry-based (no pane tags needed). Top row: leftmost
  pane is the editor (`@dev_review_pane <DEV_NAME>`), rightmost is the review
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
- `review <pr>`: `pr_url` accepts a full URL, `owner/repo#n`, or `owner/repo n`;
  `review_pane` selects the pane tagged `@dev_review_pane <profile>`; sends
  `Escape`, `:Octo <url>`, Enter, waits 2s, `:Octo review`, Enter. Browser
  fallback when the editor pane is absent or not nvim.
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
- tmux pane keybinds (send the tmux prefix + key): `cmd+d` split right,
  `cmd+shift+d` split down, `cmd+w` kill pane, `cmd+shift+enter` zoom,
  `cmd+alt+arrows` pane focus.
- GUI-editor bridges (send `Alt+<key>`; nvim maps `<A-...>`): `cmd+p`,
  `cmd+shift+p`, `cmd+s`, `cmd+f`, `cmd+shift+f`, `cmd+/`.
- `ctrl+tab` / `ctrl+shift+tab` cycle Ghostty windows (not tabs).
- Reload: `cmd+shift+,` or restart. Validate: `ghostty +validate-config`;
  inspect `ghostty +list-keybinds`. `text:` actions use Zig escapes (single
  backslash in the file); keep comments on their own lines.

## tmux

- Repo path: `~/Projects/dotfiles/.tmux.conf`, symlinked to `~/.tmux.conf`.
- Status on top (`status-position top`), tmux-nova with `mode` + `time`
  segments; pane label `#I ... #W`. Borders are `#2a2a2a` for both active and
  inactive (no green highlight).
- Plugins via tpm: tmux-resurrect, tmux-continuum, vim-tmux-navigator,
  tmux-nova.
- resurrect: `capture-pane-contents on`; `continuum-restore off`
  (dev-workspace drives restore); `@resurrect-processes '"~nvim->nvim ."'`
  (only nvim, since resurrect cannot restore a command with arguments); the
  post-restore hook runs
  `/Users/joelove/.local/bin/dev-workspace post-restore --all`, which starts the
  agent and the per-profile editor/review commands.
- `default-shell /bin/zsh`.
- terminal-features: `*:RGB` (truecolor), `xterm*:extkeys` (modified keys like
  Shift+Enter), `xterm*:hyperlinks` (OSC 8).
- `mouse on` (click to focus, scroll, border drag).
- `set-titles on` + `set-titles-string '#S'` (unique session name; used by
  dev-workspace to find each Ghostty window).
- `cursor-style blinking-block` (focused pane flashes; Ghostty hollows the
  unfocused window).
- `extended-keys on`.
- Prefix is default `C-b`. `prefix r` sources the config. `C-w` is
  context-aware: nvim focused -> `send-keys M-w` (close buffer), else
  `kill-pane`.
- `set-hook -g window-resized` runs
  `dev-workspace normalize-editor --all` (debounced).
- Inspect: `tmux show-options -g`, `tmux show-hooks -g`,
  `tmux list-keys -T prefix`.

## Neovim (NvChad v2.5 + plugins)

- Repo path: `~/Projects/dotfiles/.config/nvim`, symlinked to `~/.config/nvim`.
- Bootstrap: `init.lua` sets `mapleader = " "`, bootstraps lazy.nvim, imports
  NvChad v2.5 and `plugins`.
- `lua/mappings.lua`: `;` -> `:`, `jk` -> Esc, nvim-tree (`<leader>e` toggle,
  `ef` find, `er` refresh), GUI bridges `<A-p|P|s|f|F|/>` and `<A-w>`, octo
  `<leader>op|os|or|oc`.
- `lua/options.lua`: `guicursor` block with `blinkon500-blinkoff500`; insert
  bar, replace underline, terminal block.
- `lua/plugins/init.lua`: conform.nvim, nvim-lspconfig, nvim-tree.lua (width 35,
  git, diagnostics, shown at startup), octo.nvim (telescope picker,
  `projects_v2` warning suppressed, markdown treesitter registered).
- `lazy-lock.json` is committed.
- Theme: `lua/themes/ghostty.lua`, selected in `lua/chadrc.lua`
  (`theme = "ghostty"`), monokai-derived.
- LSP via mason: `lua_ls`, `html`, `cssls`.
- `:checkhealth octo` only finds the provider once octo has loaded (`:Octo ...`).

## octo.nvim review flow

- Install is lazy (`cmd = "Octo"`); opens from `:Octo pr list`,
  `:Octo search ...`, `:Octo <url>`, or `dev-workspace [<profile>] review`.
- Review: `:Octo review` starts review mode (files panel + side-by-side diff).
  `<localleader>ca` comment, `<localleader>sa` suggestion, `:Octo review submit`
  (Ctrl-a approve, Ctrl-m comment, Ctrl-r request changes).
- The editor pane's cwd is the project root and may not be a git repo, so use
  explicit repo/URL commands. `resurrect` drops the pane tag; `normalize_editor`
  re-adds it (`@dev_review_pane <profile>`).

## gh-dash

- Repo path: `~/Projects/dotfiles/.config/gh-dash/`, symlinked to
  `~/.config/gh-dash`.
- `config.yml` is the default profile: `prSections` lists all open PRs for
  `user:joelove`; `repoPaths` maps local checkouts; `o` runs
  `dev-workspace review ...` (default workspace).
- A project profile can keep its own gh-dash config in
  `.config/dev-workspace/<name>.yml` and set
  `DEV_REVIEW_CMD="gh dash --config ~/.config/dev-workspace/<name>.yml"`; its
  `o` binding calls the project wrapper.
- Both configs bind `enter` -> `gh pr view --web` and `o` -> review in nvim
  (overriding gh-dash's built-in open-in-GitHub; the helper falls back to the
  browser), with the same `defaults` and preview settings.
- gh-dash reads its config at launch; each workspace runs its own
  `gh dash --config ...` so the review pane shows the right sections.
- gh-dash has no Actions/workflow-runs view or section (v4.26), and the
  `status:pending` PR qualifier matches PRs whose head commit has no checks, not
  PRs with running checks. To watch running Actions, the candela profile runs
  `.local/bin/running-actions` directly below the gh-dash pane via
  `DEV_REVIEW_SUB_CMD`. It queries the REST `/actions/runs?status=in_progress`
  endpoint per repo with `gh api --cache` (default 60s) on a 30s poll loop, shows
  a live `mm:ss`/`h:mm:ss` duration that redraws every second, and resizes its
  own pane to one line per running action (clamped to 8, and effectively hidden
  at a single empty line when zero), so it and gh-dash share the right column
  dynamically.

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
  additions, `EDITOR=GIT_EDITOR=vim`, aliases `v`/`code`/`c` -> nvim, `cat` ->
  bat, git aliases, `pr` helper.
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
- Latest: generic `dev-workspace` engine + per-project profiles, one-line
  project wrappers, per-profile gh-dash configs (default all `user:joelove`,
  per-project configs under `.config/dev-workspace/`), `@dev_review_pane
  <profile>`, `set-titles-string #S`, and `dev-workspace ... --all` hooks.

## Debugging playbook

- Layout wrong after restart or resize: `dev-workspace [<profile>]
  normalize-editor` (or `ensure`); check
  `tmux list-panes -t <session> -F '#{pane_id} #{pane_width} #{pane_height} #{@dev_review_pane}'`.
- `dev-workspace` acts on the wrong server / "not running nvim": a `TMUX`
  variable is shadowing the socket env; check the engine uses `TMUX_BIN`.
- Modified keys (Shift+Enter) not working: `extended-keys`/`extkeys` need a
  fresh client attach; restart tmux or re-attach.
- GUI shortcut does nothing: verify the Ghostty bridge (`ghostty +list-keybinds`)
  and the nvim `<A-...>` map; both are required.
- Ghostty keybind sends garbage: check for inline comments or a doubled
  backslash in `text:` escapes.
- octo "No healthcheck found": load octo first (`:Octo ...`), then
  `:checkhealth octo`.
- octo/review helper can't find the repo: the editor pane cwd is the project
  root; use an explicit URL/repo.
- Review helper does nothing in gh-dash: gh-dash read the config at launch;
  relaunch it, and check the workspace's `DEV_REVIEW_CMD` config file.
- resurrect brought back old panes/options: expected; `normalize_editor`
  re-applies sizes and the review tag.
- tmux config parse errors: `tmux source-file ~/.tmux.conf` and read stderr;
  `tmux show-options -g` / `show-hooks -g` to confirm what applied.

## Improving safely

- Add a shortcut as a pair: Ghostty keybind (Alt sequence) + nvim `<A-...>` map,
  then reload both.
- Change editor sizes as profile fields (`DEV_GH_COLS`, `DEV_BOTTOM_LINES`,
  `DEV_REVIEW_SUB_LINES`); `normalize_editor` consumes them.
- Add a pane below the review pane as `DEV_REVIEW_SUB_CMD`, or a bottom-strip
  command as the matching `DEV_TERM_CMDS` entry (parallel to `DEV_TERM_DIRS`),
  not engine code; empty values omit/keep plain shells.
- Add a project as a profile in `~/.config/dev-workspace/<name>.conf` plus a
  one-line wrapper in `.local/bin/<name>-workspace`; do not fork the engine.
- Keep tmux as the only pane owner; do not introduce Ghostty splits.
- Keep the palette consistent with the existing monokai values.
- Validate before committing: `ghostty +validate-config`,
  `tmux source-file`, `bash -n dev-workspace`, `:Lazy`/`:checkhealth`.
- Commit and push `~/Projects/dotfiles`; home config is a symlink, so an
  uncommitted edit is easy to lose.
