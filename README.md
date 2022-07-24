# dotfiles

- [iterm](https://github.com/gnachman/iTerm2)
- [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- [skhd](https://github.com/koekeishiya/skhd)
- [yabai](https://github.com/koekeishiya/yabai)
- [karabiner-elements](https://github.com/pqrs-org/Karabiner-Elements)
- [fira-code-powerline](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode)

```bash
# Hide the dock
osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'
defaults write com.apple.dock orientation -string right
defaults write com.apple.Dock autohide-delay -int 999999
killall Dock

# Speed up keyboard key repeat
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
```
