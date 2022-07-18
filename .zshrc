export ZSH="$HOME/.oh-my-zsh"
export NVM="$HOME/.nvm"

export EDITOR="code"
export GIT_EDITOR="vi"

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

# Add global yarn packages to PATH
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Add local binaries to PATH
export PATH="/usr/local/bin:$PATH"

# Add node home directory modules to PATH
export PATH="$HOME/node_modules/.bin:$PATH"

# Add Make
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

# Trigger branch name update before any commands are run
precmd() {
  set_branch_name
}

# Find current branch name and export to current environment
set_branch_name() {
  if git ls-files >& /tmp/null; then
    current_branch_name=${$(git symbolic-ref -q HEAD)##refs/heads/}
    current_branch_name=${current_branch_name:-HEAD}
    export current_branch_name
  fi
}

# Push current branch to git remote master, defaulting to Heroku
gher() {
  remote=${1:-heroku}
  if [[ "$current_branch_name" == "master" ]] then
    git push $remote master
  else
    git push $remote $current_branch_name:master
  fi
}

# Murder something by port
die() {
  port=${1:-3000}
  pkill -9 $port
}

# Shorthand for installing types for an NPM package
ty() {
  yarn add --dev ${*/#/@types\/}
}

alias zshrc="$EDITOR ~/.zshrc"
alias zprofile="$EDITOR ~/.zprofile"
alias yabairc="$EDITOR ~/.yabairc"
alias skhdrc="$EDITOR ~/.skhdrc"
alias karabinerrc="$EDITOR ~/.config/karabiner/karabiner.json"

alias atom="code"
alias apm="code --install-extension"

alias yarncl="yarn cache clean && rm -rf node_modules yarn.lock && yarn"

alias gch="git checkout"
alias gn="git checkout -b"
alias gbd="git branch -d"
alias gs="git status"
alias gst="git stash"
alias gp="git pull"
alias gf="git fetch"
alias gpu='git push --set-upstream origin $current_branch_name'
alias grhh='git reset --hard origin/$current_branch_name'
alias recent="git for-each-ref --sort=-committerdate --count=5 --format='%(refname:short)' refs/heads/"
alias gdc="git diff --cached"
alias gr="git reset"
alias gpsh="git push"
alias gl="git log"
alias gstk="git stash --keep-index"
alias grb="git rebase"
alias gpm="git pull origin master:master"
alias grbm="gpm && grb master"
alias gpsht='git push origin "$current_branch_name":test'
alias glg='git log --graph --pretty=oneline --all --abbrev-commit'

# alias dsa="docker stop $(docker ps -q)"
# alias drma="docker rm $(docker ps -q)"
# alias dpra="docker image prune -a"
