# dotfiles

### Install

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
```

### Configure

- [skhd](https://github.com/koekeishiya/skhd)
- [yabai](https://github.com/koekeishiya/yabai)
- [Ghostty](https://ghostty.org) (config symlinked from `.config/ghostty`)
- [tmux](https://github.com/tmux/tmux) with tpm plugins (see `.tmux.conf`)
- [Neovim](https://neovim.io) NvChad-based config (symlinked from `.config/nvim`)
- `dev-workspace` tmux/Ghostty workspace engine with per-project profiles (symlinked from `.local/bin` and `.config/dev-workspace`); needs `tmux`, `jq`, `yabai`

### Symlinks

```sh
ln -s ~/Projects/dotfiles/.zshrc ~/.zshrc
ln -s ~/Projects/dotfiles/.zprofile ~/.zprofile
ln -s ~/Projects/dotfiles/.zshenv ~/.zshenv
ln -s ~/Projects/dotfiles/.skhdrc ~/.skhdrc
ln -s ~/Projects/dotfiles/.yabairc ~/.yabairc
ln -s ~/Projects/dotfiles/.automations.sh ~/.automations.sh
ln -s ~/Projects/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/Projects/dotfiles/.gitignore ~/.gitignore
ln -s ~/Projects/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/Projects/dotfiles/.p10k.zsh ~/.p10k.zsh
mkdir -p ~/.config
ln -s ~/Projects/dotfiles/.config/ghostty ~/.config/ghostty
ln -s ~/Projects/dotfiles/.config/nvim ~/.config/nvim
ln -s ~/Projects/dotfiles/.config/gh-dash ~/.config/gh-dash
ln -s ~/Projects/dotfiles/.config/dev-workspace ~/.config/dev-workspace
mkdir -p ~/.local/bin
ln -s ~/Projects/dotfiles/.local/bin/dev-workspace ~/.local/bin/dev-workspace
ln -s ~/Projects/dotfiles/.local/bin/running-actions ~/.local/bin/running-actions
ln -s ~/Projects/dotfiles/.local/bin/audit-agent-context.mjs ~/.local/bin/audit-agent-context
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
