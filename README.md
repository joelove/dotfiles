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
# per-project wrappers (one-line `exec dev-workspace <profile> "$@"`) are added alongside
mkdir -p ~/.agents/skills ~/.pi/agent/skills
ln -s ~/Projects/dotfiles/.agents/skills/github-prs ~/.agents/skills/github-prs
ln -s ~/.agents/skills/github-prs ~/.pi/agent/skills/github-prs
ln -s ~/Projects/dotfiles/.agents/skills/local-dev-environment ~/.agents/skills/local-dev-environment
ln -s ~/.agents/skills/local-dev-environment ~/.pi/agent/skills/local-dev-environment
```

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
