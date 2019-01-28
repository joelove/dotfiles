export ZSH="/Users/$(id -un)/.oh-my-zsh"
export EDITOR="atom"
export GIT_EDITOR="vi"

ZSH_THEME="agnoster"
DEFAULT_USER="$(id -un)"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Add bin to PATH
export PATH="/usr/local/bin:$PATH"

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Load direnv
eval "$(direnv hook zsh)"

precmd() {
  set_branch_name
}

set_branch_name() {
  if git ls-files >& /tmp/null; then
    current_branch_name=${$(git symbolic-ref -q HEAD)##refs/heads/}
    current_branch_name=${current_branch_name:-HEAD}
    export current_branch_name
  fi
}

gher() {
  remote=${1:-heroku}
  if [[ "$current_branch_name" == "master" ]] then
    git push $remote master
  else
    git push $remote $current_branch_name:master
  fi
}

alias zshrc="atom ~/.zshrc"

alias gch="git checkout"
alias gn="git checkout -b"
alias gs="git status"
alias gst="git stash"
alias gp="git pull"
alias gpu='git push --set-upstream origin $current_branch_name'
alias grhh='git reset --hard origin/$current_branch_name'
alias recent="git for-each-ref --sort=-committerdate --count=5 --format='%(refname:short)' refs/heads/"
alias gdc="git diff --cached"
alias gr="git reset"
alias gpsh="git push"
alias gl="git log"
alias gstk="git stash --keep-index"
