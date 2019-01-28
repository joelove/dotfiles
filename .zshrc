export ZSH="/Users/$(id -un)/.oh-my-zsh"
export EDITOR="atom"
export GIT_EDITOR="vi"

ZSH_THEME="agnoster"
DEFAULT_USER="$(id -un)"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Add bin to PATH
export PATH="/usr/local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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
