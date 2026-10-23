# dotfiles

### Install

> These are the vendors' documented installers. Review them before running.
> This repo does not ship a bootstrap script that pipes unpinned or plain-HTTP
> scripts into a shell.

https://brew.sh/

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 🍺

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

brew install jq
brew install fzf
brew install zoxide
brew install bat
brew install mdcat
brew instal ripgrep
brew install 1password-cli
brew install postgresql@17
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
brew install --cask raycast
brew install --cask iterm2
brew install --cask visual-studio-code
brew install --cask cursor
brew install --cask karabiner-elements
brew install --cask logi-options+
brew install koekeishiya/formulae/skhd
brew install koekeishiya/formulae/yabai

# croft: the personal fork (joelove/croft, branch personal)
git clone --branch personal https://github.com/joelove/croft.git ~/Projects/croft
(cd ~/Projects/croft && cargo install --path . --locked)

# lumen: the personal fork (joelove/lumen, branch personal) with an ANSI theme
git clone --branch personal https://github.com/joelove/lumen.git ~/Projects/lumen
(cd ~/Projects/lumen && cargo install --path . --locked)

# whisper.cpp: local, offline dictation for pi-speech (joelove/whisper.cpp fork)
brew install cmake ffmpeg
sh ~/Projects/dotfiles/scripts/setup-whisper.sh   # build, model, ~/.local/bin, LaunchAgent
```

### Configure

- [skhd](https://github.com/koekeishiya/skhd)
- [yabai](https://github.com/koekeishiya/yabai)
- [Ghostty](https://ghostty.org) (config symlinked from `.config/ghostty`)
- [tmux](https://github.com/tmux/tmux) with tpm plugins (see `.tmux.conf`)
- [croft](https://docs.croft.software) VS Code-style terminal editor (built from the `joelove/croft` fork branch `personal`; config symlinked from `.config/croft`; run `croft setup-ghostty` once for the Cmd chords)
- [lumen](https://github.com/jnsahaj/lumen) PR diff/review TUI (built from the `joelove/lumen` fork branch `personal`, which adds the `ansi` theme so it matches the terminal palette; config symlinked from `.config/lumen`)
- [mdcat](https://github.com/BIRSAx2/mdcat) markdown renderer, `brew install mdcat` (config symlinked from `.config/mdcat`; `mdpick`/`mdless` wrappers in `.local/bin`)
- [pi-speech](https://github.com/jkeskikangas/pi-mobile/tree/main/packages/pi-speech) dictation for pi (installed from the `joelove/pi-mobile` fork branch `personal`, which adds the `PI_SPEECH_STT_URL` override); recognition runs against the local `whisper-server` from `scripts/setup-whisper.sh`, so it is free and offline. Start it with `alt+m` in pi or the global `cmd+alt+d`; pi then distils the speech into a clean prompt (or a structured draft) in the editor
- `repo-review` review-tab picker: fzf over a profile's gh-dash `repoPaths`, then a per-repo worktree picker (primary checkout plus linked worktrees; Esc keeps the current branch), then `lumen diff` in the chosen directory (symlinked from `.local/bin`)
- `dev-workspace` tmux/Ghostty workspace engine with per-project profiles (symlinked from `.local/bin`; profiles live in `~/.config/dev-workspace`); needs `tmux`, `jq`, `yabai`. Shell launcher `ws [DIR]` (default `~/Projects`, or root the same layout at DIR) opens or focuses the workspace windows. Project profiles, for example a company workspace, come from the private overlay below

### Symlinks

```sh
ln -s ~/Projects/dotfiles/.zshrc ~/.zshrc
ln -s ~/Projects/dotfiles/.zprofile ~/.zprofile
ln -s ~/Projects/dotfiles/.zshenv ~/.zshenv
ln -s ~/Projects/dotfiles/.skhdrc ~/.skhdrc   # overlay/link.sh regenerates it
ln -s ~/Projects/dotfiles/.yabairc ~/.yabairc
ln -s ~/Projects/dotfiles/.automations.sh ~/.automations.sh
ln -s ~/Projects/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/Projects/dotfiles/.gitignore ~/.gitignore
ln -s ~/Projects/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/Projects/dotfiles/.p10k.zsh ~/.p10k.zsh
mkdir -p ~/.config
ln -s ~/Projects/dotfiles/.config/ghostty ~/.config/ghostty
ln -s ~/Projects/dotfiles/.config/croft ~/.config/croft
ln -s ~/Projects/dotfiles/.config/gh-dash ~/.config/gh-dash
mkdir -p ~/.config/dev-workspace   # dev-workspace profiles (private overlay)
ln -s ~/Projects/dotfiles/.config/lumen ~/.config/lumen
ln -s ~/Projects/dotfiles/.config/mdcat ~/.config/mdcat
mkdir -p ~/.local/bin
ln -s ~/Projects/dotfiles/.local/bin/dev-workspace ~/.local/bin/dev-workspace
ln -s ~/Projects/dotfiles/.local/bin/croft-edit ~/.local/bin/croft-edit
ln -s ~/Projects/dotfiles/.local/bin/dev-docs ~/.local/bin/dev-docs
ln -s ~/Projects/dotfiles/.local/bin/repo-review ~/.local/bin/repo-review
ln -s ~/Projects/dotfiles/.local/bin/mdpick ~/.local/bin/mdpick
ln -s ~/Projects/dotfiles/.local/bin/mdless ~/.local/bin/mdless
ln -s ~/Projects/dotfiles/.local/bin/running-actions ~/.local/bin/running-actions
ln -s ~/Projects/dotfiles/.local/bin/audit-agent-context.mjs ~/.local/bin/audit-agent-context
# pi agent config and the git-guard hooks (idempotent; backs up any real file).
sh ~/Projects/dotfiles/scripts/setup-pi.sh
# All public skills live in dotfiles; pi discovers ~/.agents/skills natively, so
# symlink every skill directory back. Do not mirror into ~/.pi/agent/skills.
mkdir -p ~/.agents/skills
for d in ~/Projects/dotfiles/.agents/skills/*/; do
  ln -sfn "$d" "$HOME/.agents/skills/$(basename "$d")"
done

# Privileged skills (production DB access, CMS admin) live in a private repo,
# not here. Clone agent-skills and link it the same way.
for d in ~/Projects/agent-skills/.agents/skills/*/; do
  ln -sfn "$d" "$HOME/.agents/skills/$(basename "$d")"
done
```

### Skills: public vs private

- **Public** skills live in `dotfiles/.agents/skills` and are safe to publish.
- **Private** skills live in the private `agent-skills` repo under
  `.agents/skills`. Company specifics, production access, and anything unsafe
  (an auth bypass, internal hostnames, repo lists) belong here, never in
  `dotfiles`. Examples: the app design loop, the local dev environment, and the
  company workflow skills.
- Both repos are symlinked into `~/.agents/skills`, so pi discovers them the
  same way. Do not mirror skills into `~/.pi/agent/skills`.

### Private overlay

The public configs stay generic and compose with a private overlay from the
`agent-skills` repo (`overlay/`). Run `agent-skills/overlay/link.sh` to install
it. Include points:

- `.zshrc` conditionally sources `~/.config/dotfiles/private.zsh`
- `.tmux.conf` runs `source-file -q ~/.config/dotfiles/tmux.conf`
- `.config/ghostty/config` has `config-file = ?~/.config/dotfiles/ghostty.conf`
- `dev-workspace` reads profiles from `~/.config/dev-workspace/`
- skhd has no include, so `link.sh` generates `~/.skhdrc` from
  `dotfiles/.skhdrc` plus the private fragment

Every include is absent-safe: without the overlay the public configs load
unchanged and simply lack the company bindings.

### Forks

Heavily customized tools run from a fork with a `personal` branch, and the
upstream stays read-only (never merged or rebased). This keeps local changes
from being overwritten and limits exposure to upstream supply-chain changes.
`croft`, `lumen`, and `pi-plan-build` follow this shape: `origin` is the
`joelove` fork, `upstream` is the original.

### Agent context

`audit-agent-context` reports what pi advertises into context for a repo, using
pi's own resource loader. Run it against any repo:

```sh
cd ~/Projects/my-app
node ~/Projects/dotfiles/.local/bin/audit-agent-context.mjs --cwd .
node ~/Projects/dotfiles/.local/bin/audit-agent-context.mjs --cwd . --check --context-max 4096
```

`--repo NAME` resolves against `$AGENT_AUDIT_ROOT` (default `~/Projects`).
It prints the advertised skills with description and body bytes, the hidden
skills, and the context-file bytes. `--check` exits non-zero above 13 advertised
skills or 4,000 description bytes; `--context-max` adds a context-file cap. The
2026-09 streamlining pass took a repo from 24 advertised skills to 9-10 and from
~7.5KB of descriptions to ~2.2KB, and the git/Linear cluster from ~30.7KB of
body to a single short router.

```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### Useful

```bash
# Hide the dock
osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'
defaults write com.apple.dock orientation -string right
defaults write com.apple.Dock autohide-delay -int 999999
killall Dock

# Speed up keyboard key repeat
defaults write -g InitialKeyRepeat -int 20
defaults write -g KeyRepeat -int 1

# Create and default screenshots directory
mkdir -p $HOME/Screenshots
defaults write com.apple.screencapture location "${HOME}/Screenshots"
killall SystemUIServer
```

### Notes

> _**yabai doesn't play well with Apple Silicon and MacOS Monterey yet, go nuts**:_
>
> - ~~_https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(from-HEAD)_~~
> - _https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection_
> - _https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition_
>
> ~~🚀 _https://github.com/koekeishiya/yabai/issues/1054_~~
