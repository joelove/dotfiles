#!/bin/sh

# Install Xcode Command Line Tools
os=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
if softwareupdate --history | grep --silent "Command Line Tools.*${os}"; then
  echo 'Xcode Command Line Tools already installed.'
else
  echo 'Installing Xcode Command Line Tools...'
  in_progress=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  touch ${in_progress}
  product=$(softwareupdate --list | awk "/\* Command Line.*${os}/ { sub(/^   \* /, \"\"); print }")
  softwareupdate --verbose --install "${product}" || echo 'Installation failed.' 1>&2 && rm ${in_progress} && exit 1
  rm ${in_progress}
  echo 'Installation succeeded.'
fi

# Install Homebrew
which -s brew
if [[ $? != 0 ]] ; then
  echo 'Installing Homebrew...'
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
else
  echo 'Updating Homebrew...'
  brew update
fi

# Install iTerm
if [ -d '/Applications/iTerm.app' ]; then
  echo 'iTerm already installed.'
else
  echo 'Installing iTerm...'
  curl -Ls https://iterm2.com/downloads/stable/latest | gunzip -dcq
  mv iTerm.app /Applications/
  sudo spctl --add /Applications/iTerm.app/
fi

# Install ZSH
which -s zsh
if [[ $? != 0 ]] ; then
  echo 'Installing ZSH...'
  brew install zsh
else
  echo 'ZSH already installed.'
fi

# Install Oh My Zsh
if [ -d "/Users/$(id -un)/.oh-my-zsh" ]; then
  echo 'Oh My Zsh already installed.'
else
  echo 'Installing Oh My Zsh...'
  curl -L http://install.ohmyz.sh | sh
fi

# Install Spectacle
if [ -d '/Applications/Spectacle.app' ]; then
  echo 'Spectacle already installed.'
else
  echo 'Installing Spectacle...'
  brew cask install spectacle
  sudo spctl --add /Applications/Spectacle.app/
fi

# Install Fura Code font
if [ -f "/Users/$(id -un)/Library/Fonts/Fura\ Code.ttf" ]; then
  echo 'Fura Code font already installed.'
else
  echo 'Installing Fura Code font...'
  cd ~/Library/Fonts
  curl -o Fura\ Code.ttf https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fura%20Code%20Regular%20Nerd%20Font%20Complete.ttf
  cd -
fi

# Install NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
zsh

# Install Node
nvm install stable
nvm use --delete-prefix stable
nvm alias default stable

# Install Yarn
brew install yarn --without-node

# Hide the dock
osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'
defaults write com.apple.dock orientation -string right
defaults write com.apple.Dock autohide-delay -int 999999
killall Dock

# Speed up keyboard key repeat
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

#!/bin/sh

# Install Xcode Command Line Tools
os=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
if softwareupdate --history | grep --silent "Command Line Tools.*${os}"; then
  echo 'Xcode Command Line Tools already installed.'
else
  echo 'Installing Xcode Command Line Tools...'
  in_progress=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  touch ${in_progress}
  product=$(softwareupdate --list | awk "/\* Command Line.*${os}/ { sub(/^   \* /, \"\"); print }")
  softwareupdate --verbose --install "${product}" || echo 'Installation failed.' 1>&2 && rm ${in_progress} && exit 1
  rm ${in_progress}
  echo 'Installation succeeded.'
fi

# Install Homebrew
which -s brew
if [[ $? != 0 ]] ; then
  echo 'Installing Homebrew...'
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
else
  echo 'Updating Homebrew...'
  brew update
fi

# Install iTerm
if [ -d '/Applications/iTerm.app' ]; then
  echo 'iTerm already installed.'
else
  echo 'Installing iTerm...'
  curl -Ls https://iterm2.com/downloads/stable/latest | gunzip -dcq
  mv iTerm.app /Applications/
  sudo spctl --add /Applications/iTerm.app/
fi

# Install ZSH
which -s zsh
if [[ $? != 0 ]] ; then
  echo 'Installing ZSH...'
  brew install zsh
else
  echo 'ZSH already installed.'
fi

# Install Oh My Zsh
if [ -d "/Users/$(id -un)/.oh-my-zsh" ]; then
  echo 'Oh My Zsh already installed.'
else
  echo 'Installing Oh My Zsh...'
  curl -L http://install.ohmyz.sh | sh
fi

# Install Spectacle
if [ -d '/Applications/Spectacle.app' ]; then
  echo 'Spectacle already installed.'
else
  echo 'Installing Spectacle...'
  brew cask install spectacle
  sudo spctl --add /Applications/Spectacle.app/
fi

# Install Fura Code font
if [ -f "/Users/$(id -un)/Library/Fonts/Fura\ Code.ttf" ]; then
  echo 'Fura Code font already installed.'
else
  echo 'Installing Fura Code font...'
  cd ~/Library/Fonts
  curl -o Fura\ Code.ttf https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fura%20Code%20Regular%20Nerd%20Font%20Complete.ttf
  cd -
fi

# Install NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
zsh

# Install Node
nvm install stable
nvm use --delete-prefix stable
nvm alias default stable

# Install Yarn
brew install yarn --without-node

# Hide the dock
osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'
defaults write com.apple.dock orientation -string right
defaults write com.apple.Dock autohide-delay -int 999999
killall Dock

# Speed up keyboard key repeat
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

# Edit git config
git config --global user.name "Joe Love"
git config --global user.email git@joelove.uk
