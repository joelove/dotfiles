# dotfiles

### Install
- [iterm](https://github.com/gnachman/iTerm2)
- [homebrew](https://brew.sh/)

### 🍺

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install jq
brew tap homebrew/cask-fonts
brew install --cask font-fira-code
brew install --cask raycast
brew install --cask iterm2
brew install --cask visual-studio-code
brew install koekeishiya/formulae/skhd
brew install koekeishiya/formulae/yabai
```

### Configure

- [skhd](https://github.com/koekeishiya/skhd)
- [yabai](https://github.com/koekeishiya/yabai)

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
```

### Manual
- [Logitech Options +](https://support.logi.com/hc/en-ch/articles/8335872743575-Download-MX-Master-3S-for-Mac)
- [Fira Code](https://github.com/tonsky/FiraCode)
- [oh-my-zsh](https://ohmyz.sh/#install)

### Optional

- [karabiner-elements](https://github.com/pqrs-org/Karabiner-Elements)

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
```

### Notes

> _**yabai doesn't play well with Apple Silicon and MacOS Monterey yet, go nuts**:_
>
> ~~_https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(from-HEAD)_~~
> _https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection_
>
> 🚀 _https://github.com/koekeishiya/yabai/issues/1054_
