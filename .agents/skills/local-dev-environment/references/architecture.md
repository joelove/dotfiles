# Local dev environment: architecture and configuration

Exhaustive per-tool detail. `SKILL.md` has the invariants and the quick map;
this file is the reference for changing or debugging anything.

## Sessions and layout (`candela-workspace`)

- Repo path: `~/Projects/dotfiles/.local/bin/candela-workspace`, symlinked to
  `~/.local/bin/candela-workspace`. Sets its own `PATH` and uses absolute
  `SELF`/`PI_BIN` paths so it works from `open`/launchd.
- Two tmux sessions, one window each:
  - `candela-pi`, window `agent`: two panes, both `pi` in `~/Projects/candela`.
  - `candela-prs`, window `editor`: four panes. Top-left `nvim .` (in
    `~/Projects/candela`), top-right `gh dash`, bottom-left/right shells in
    `candela-infra` / `candela-orchestrator`.
- Subcommands: `build`, `ensure`, `attach [session]`, `attach-only [session]`,
  `open`, `review <pr>`, `normalize-editor`, `post-restore`.
- `open`: `ensure`, then opens one Ghostty instance with the two windows via
  AppleScript `new window with configuration` (a fresh launch uses
  `--initial-window=false`). If both sessions already have clients it just
  focuses: `focus_workspace_windows` finds each window by its title
  (`agent`/`editor`, from tmux `set-titles`) and uses `yabai -m window --focus`
  to swap each display to the window's space.
- `ensure`: restores from the newest tmux-resurrect save when a session is
  missing, then `build`, then `normalize_editor`. A lock dir prevents concurrent
  runs.
- `normalize_editor`: geometry-based re-pin, independent of pane names/options.
  The smallest `pane_top` is the top row; its rightmost pane is gh-dash
  (`-x 76`) and its leftmost is nvim (`@candela_review_pane 1`). The largest
  `pane_top` is the bottom row; its leftmost pane is resized to `-y 14`. Called
  from `ensure`, from `post_restore`, and from the tmux `window-resized` hook
  via the debounced `normalize-editor` subcommand (0.25s quiet period).
- `build_prs`/`build_pi` define the layout on first creation: gh-dash `-l 76`,
  bottom strip `-l 14`, `@candela_review_pane 1` on the nvim pane.
- `review <ref>`: `pr_url` accepts a full URL, `owner/repo#n`, or
  `owner/repo n`. `review_pane` finds the pane tagged `@candela_review_pane`.
  It sends `Escape`, `:Octo <url>`, Enter, waits 2s, then `:Octo review`, Enter
  (octo fetches asynchronously). Falls back to `open <url>` when the editor pane
  is absent or not running nvim.
- `post_restore`: survives `resurrect` restoring `pi` as a bare `node`; starts
  pi in shell panes and re-normalizes.
- Never name a shell variable `TMUX` in this script or its callers: it shadows
  tmux's exported socket variable, so child `tmux` clients try to connect to the
  value as a socket. The script uses `TMUX_BIN`.

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
- resurrect: `capture-pane-contents on`; `continuum-restore off` (candela-workspace
  drives restore); `@resurrect-processes '"~gh->gh dash" "~nvim->nvim ."'`;
  post-restore hook `/Users/joelove/.local/bin/candela-workspace post-restore`.
- `default-shell /bin/zsh`.
- terminal-features: `*:RGB` (truecolor), `xterm*:extkeys` (modified keys like
  Shift+Enter), `xterm*:hyperlinks` (OSC 8).
- `mouse on` (click to focus, scroll, border drag).
- `set-titles on` + `set-titles-string '#W'` (window name; candela-workspace
  matches `agent`/`editor`).
- `cursor-style blinking-block` (focused pane flashes; Ghostty hollows the
  unfocused window).
- `extended-keys on`.
- Prefix is default `C-b`. `prefix r` sources the config. `C-w` is
  context-aware: nvim focused -> `send-keys M-w` (close buffer), else
  `kill-pane`.
- `set-hook -g window-resized` runs `candela-workspace normalize-editor`.
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
  `:Octo search is:pr org:Candela-Ed`, `:Octo <url>`, or `candela-workspace review`.
- Review: `:Octo review` starts review mode (files panel + side-by-side diff).
  `<localleader>ca` comment, `<localleader>sa` suggestion, `:Octo review submit`
  (Ctrl-a approve, Ctrl-m comment, Ctrl-r request changes).
- The editor pane's cwd is `~/Projects/candela`, which is not a git repo, so use
  explicit repo/URL commands. `resurrect` drops the pane tag; `normalize_editor`
  re-adds it.

## gh-dash

- Repo path: `~/Projects/dotfiles/.config/gh-dash/config.yml`, symlinked to
  `~/.config/gh-dash`.
- `prSections`: "Candela: open PRs" across candela-match, candela-eval,
  candela-orchestrator, candela-infra, candela-cms.
- `repoPaths` map each repo to its checkout for checkout/diff.
- `defaults`: `view: prs`, `prsLimit: 50`, `refetchIntervalMinutes: 5`,
  preview open.
- `keybindings.prs`: `enter` -> `gh pr view --web`; `o` -> `candela-workspace
  review https://github.com/{{.RepoName}}/pull/{{.PrNumber}}` (overrides the
  built-in open-in-GitHub; the helper falls back to the browser).
- Config is read at launch; relaunch `gh dash` to reload.

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
  bat, git aliases, `pr` helper, `CANDELA_UI_READ_TOKEN="$(gh auth token)"`.
- `.zprofile`, `.zshenv` (sources `.automations.sh`), `.p10k.zsh`.
- `.gitconfig`: identity plus `gh auth git-credential` helpers for github.com
  and gist.github.com.

## skhd and yabai

- `.skhdrc` (symlinked): `cmd+alt+tab` -> `candela-workspace open`;
  `cmd+alt+shift+arrows` -> yabai spatial focus (window, else display);
  window sizing hotkeys (`ctrl+alt+cmd`/`ctrl+cmd+shift` + space/x/c/z/tilde);
  move window across displays; `hyper+1..4` app launches; `cmd+esc` dual-mac
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

- 2026-09-21 `2989f60` Add Ghostty, Neovim and candela-workspace configs;
  symlink Ghostty, nvim, gh-dash, candela-workspace.
- 2026-09-23 `f4345b0` octo.nvim + open-PR-for-review integration (review
  subcommand, gh-dash binding, github-prs skill, gh-dash config in dotfiles).
- 2026-09-23 `0d65df3` gh-dash `o` bound to review-in-nvim.
- 2026-09-23 `9c84d0d` `candela-workspace` TMUX_BIN fix.
- 2026-09-23 `33d34c4` tolerant `review_pane`.
- 2026-09-23 `669a25c`, `55161d7`, `f6996d7`, `d91d7a1`: fixed editor sizes
  (gh-dash 80/76 cols, bottom 16/20/14 lines) re-pinned by `normalize_editor`.
- 2026-09-23 `f50ae50` normalize on ensure/restore; `4c65d9b` `window-resized`
  hook.
- Earlier in the week (in `.tmux.conf`/skhd): tmux-nova subtle borders, mouse,
  titles, blinking cursor, extended-keys/hyperlinks, `C-w` kill, `cmd+alt+tab`
  workspace open, spatial focus.

## Debugging playbook

- Layout wrong after restart or resize: `candela-workspace normalize-editor`
  (or `ensure`); check `tmux list-panes -t candela-prs -F '#{pane_id} #{pane_width} #{pane_height} #{@candela_review_pane}'`.
- `candela-workspace` acts on the wrong server / "not running nvim": a `TMUX`
  variable is shadowing the socket env; check the script uses `TMUX_BIN`.
- Modified keys (Shift+Enter) not working: `extended-keys`/`extkeys` need a
  fresh client attach; restart tmux or re-attach.
- GUI shortcut does nothing: verify the Ghostty bridge (`ghostty +list-keybinds`)
  and the nvim `<A-...>` map; both are required.
- Ghostty keybind sends garbage: check for inline comments or a doubled
  backslash in `text:` escapes.
- octo "No healthcheck found": load octo first (`:Octo ...`), then
  `:checkhealth octo`.
- octo/review helper can't find the repo: the editor pane cwd is the umbrella
  dir; use an explicit URL/repo.
- Review helper does nothing in gh-dash: gh-dash read the config at launch;
  relaunch it.
- resurrect brought back old panes/options: expected; `normalize_editor`
  re-applies sizes and the review tag.
- tmux config parse errors: `tmux source-file ~/.tmux.conf` and read stderr;
  `tmux show-options -g` / `show-hooks -g` to confirm what applied.

## Improving safely

- Add a shortcut as a pair: Ghostty keybind (Alt sequence) + nvim `<A-...>` map,
  then reload both.
- Change editor sizes in `build_prs` and `normalize_editor` together.
- Keep tmux as the only pane owner; do not introduce Ghostty splits.
- Keep the palette consistent with the existing monokai values.
- Validate before committing: `ghostty +validate-config`,
  `tmux source-file`, `bash -n candela-workspace`, `:Lazy`/`:checkhealth`.
- Commit and push `~/Projects/dotfiles`; home config is a symlink, so an
  uncommitted edit is easy to lose.
