export ZSH="$HOME/.oh-my-zsh"
export NVM="$HOME/.nvm"

ZSH_THEME="agnoster"
DEFAULT_USER="$(id -un)"

plugins=(
  git
  npm
  macos
  yarn
  node
  aws
  history
)

source $ZSH/oh-my-zsh.sh

# Use pyenv for Python version
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Use rtx for Node version
if command -v rtx 1>/dev/null 2>&1; then
  eval "$($(which rtx) activate zsh)"
fi

# Add Volta to PATH
export PATH="$VOLTA_HOME/bin:$PATH"

# Add global yarn packages to PATH
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Add local binaries to PATH
export PATH="/usr/local/bin:$PATH"

# Add Node home directory modules to PATH
export PATH="$HOME/node_modules/.bin:$PATH"

# Add Make to PATH
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

# Set default editors
export EDITOR="code"
export GIT_EDITOR="vi"

# Output colors
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
orange=$(tput setaf 3)
purple=$(tput setaf 4)
cyan=$(tput setaf 6)

# Trigger branch name update before any commands are run
precmd() {
  set_branch_name
}

# Don't add delete history commands to ZSH history
zshaddhistory() {
 [[ $1 != 'dc '* ]]
}

# Delete a line from history by index, i.e. dc -2
dc () {
  local HISTORY_IGNORE="${(b)$(fc -ln $1 $1)}"
  fc -W
  fc -p $HISTFILE $HISTSIZE $SAVEHIST
  print "Deleted '$green$HISTORY_IGNORE$normal' from history."
}

# Find current branch name and export to current environment
set_branch_name() {
  if git ls-files >& /tmp/null; then
    current_branch_name=${$(git symbolic-ref -q HEAD)##refs/heads/}
    current_branch_name=${current_branch_name:-HEAD}
    export current_branch_name
  fi
}

# Push current branch to git remote main, defaulting to Heroku
gher() {
  remote=${1:-heroku}
  if [[ "$current_branch_name" == "main" ]] then
    git push $remote main
  else
    git push $remote $current_branch_name:main
  fi
}

# Murder something by port
die() {
  port=${1:-3000}
  pkill -9 $port
}

# Shorthand for installing types for an NPM package
ty() {
  npm add -D ${*/#/@types\/}
}

# List recent Git branches
recent() {
  git for-each-ref --sort=-committerdate --count="${1:-5}" --format='%(refname:short)' refs/heads/
}

# Turn on or off local SSL proxy
proxy() {
  kill %?local-ssl-proxy || local-ssl-proxy --source ${1:-3010} --target ${2:-3000} --cert ~/localhost.pem --key ~/localhost-key.pem &
}

alias v="vim"
alias vim="nvim"
alias ts="npx ts-node"

# Configs
alias zshrc="$EDITOR ~/.zshrc"
alias zprofile="$EDITOR ~/.zprofile"
alias yabairc="$EDITOR ~/.yabairc"
alias skhdrc="$EDITOR ~/.skhdrc"
alias karabinerrc="$EDITOR ~/.config/karabiner/karabiner.json"

# Docker
# alias dsa="docker stop $(docker ps -q)"
# alias drm="docker rm -f $(docker ps -a -q)"
# alias dvrm="docker volume rm $(docker volume ls -q)"
# alias dpra="docker image prune -a"

# Git
alias gch="git checkout"
alias gn="git checkout -b"
alias gbd="git branch -d"
alias gs="git status"
alias gst="git stash"
alias gp="git pull"
alias gf="git fetch"
alias gpu='git push --set-upstream origin $current_branch_name'
alias grhh='git reset --hard origin/$current_branch_name'
alias gdc="git diff --cached"
alias gr="git reset"
alias gpsh="git push"
alias gl="git log"
alias gstk="git stash --keep-index"
alias grb="git rebase"
alias gpm="git pull origin main:main"
alias grbm="gpm && grb main"
alias gpsht='git push origin "$current_branch_name":test'
alias glg='git log --graph --pretty=oneline --all --abbrev-commit'
alias gca='git commit --amend -C head'
alias gcc='git commit -C head'
