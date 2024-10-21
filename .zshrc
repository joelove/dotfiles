# if [[ "$TERM" != "screen" ]] && [[ "$SSH_CONNECTION" == "" ]]; then
#   WHOAMI=$(whoami)
#   if tmux has-session -t $WHOAMI 2>/dev/null; then
#     tmux -2 attach-session -t $WHOAMI
#   else
#     tmux -2 new-session -s $WHOAMI
#   fi
# fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

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

# Use zoxide for directory navigation
if command -v zoxide 1>/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Use fzf for fuzzy matching
if command -v zoxide 1>/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

# Use pyenv for Python version
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Use mise for Node version
if command -v mise 1>/dev/null 2>&1; then
  eval "$($(which mise) activate zsh)"
fi

# Add PNPM to PATH
export PNPM_HOME="$HOME/Library/pnpm"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Add Volta to PATH
export PATH="$VOLTA_HOME/bin:$PATH"

# Add global yarn packages to PATH
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Add local binaries to PATH
export PATH="/usr/local/bin:$PATH"

# Add user binaries to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add Node home directory modules to PATH
export PATH="$HOME/node_modules/.bin:$PATH"

# Add Make to PATH
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

# Set default editors
export EDITOR="code"
export GIT_EDITOR="nvim"

# Output formatting
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
orange=$(tput setaf 3)
purple=$(tput setaf 4)
cyan=$(tput setaf 6)

# Trigger branch name update before any commands are run
precmd() {
  # set_current_branch
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
set_current_branch() {
  if git ls-files >& /tmp/null; then
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    export current_branch
  fi
}

# Push current branch to git remote main, defaulting to origin
gpshr() {
  remote=${1:-origin}
  set_current_branch

  if [[ "$current_branch" == "main" ]] then
    git push $remote main
  else
    git push $remote $current_branch:main
  fi
}

# Murder something by port
die() {
  port=${1:-3000}
  pid=$(lsof -n -i4TCP:$port | grep -m 1 LISTEN | awk '{ print $2 }')
  kill -9 $pid
}

# Shorthand for installing types for an NPM package
ty() {
  npm add -D ${*/#/@types\/}
}

# List recent Git branches
recent() {
  echo "${bold}Recent branches${normal}:"
  git for-each-ref --sort=-committerdate --count="${1:-10}" --format='%(refname:short)' refs/heads/
}

# Turn on or off local SSL proxy
proxy() {
  kill %?local-ssl-proxy || local-ssl-proxy --source ${1:-3010} --target ${2:-3000} --cert ~/localhost.pem --key ~/localhost-key.pem &
}

# List all terminal colors
colors() {
  for i in {0..255}; do
    print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
  done
}

# Manually deploy a single service
deploy() {
  if [ $# -lt 1 ]; then
    gh run list --workflow=manual-deploy-service.yml --branch="$(git rev-parse --abbrev-ref HEAD)" --limit=5

    echo "Usage: $funcstack[1] [service] [branch=current] [environment=testing]"
    exit 2
  fi

  if ! command -v gh 2>&1 >/dev/null; then
    brew install gh
    gh auth login
  fi

  service=$1
  branch=${2:-$(git rev-parse --abbrev-ref HEAD)}
  environment=${3:-testing}

  echo "Deploying $service to $environment ($branch)"

  gh workflow run manual-deploy-service.yml -r "$branch" -F environment-name="$environment" -F ref="$branch" -F package-name="$service"
}

# general
alias v='vim'
alias vim='nvim'
alias ts='npx ts-node'
alias r='recent'
alias cat='bat'
alias catp='bat -p'
alias d='deploy'
alias scb='set_current_branch'

# configs
alias zshrc="$EDITOR ~/.zshrc"
alias zprofile="$EDITOR ~/.zprofile"
alias yabairc="$EDITOR ~/.yabairc"
alias skhdrc="$EDITOR ~/.skhdrc"
alias karabinerrc="$EDITOR ~/.config/karabiner/karabiner.json"
alias tmuxrc="$EDITOR ~/.tmux.conf"
alias p10krc="$EDITOR ~/.p10k.zsh"

# docker
alias dsa='docker stop "$(docker ps -q)"'
alias drm='docker rm -f "$(docker ps -a -q)"'
alias dvrm='docker volume rm "$(docker volume ls -q)"'
alias dpra='docker image prune -a'

# tmux
alias tma='tmux attach'
alias tmd='tmux detach'
alias tml='tmux list-panes -a -F "#{pane_tty} #{session_name}"'

# aws
alias ass='assume maze_developer'

# git
alias gbd='git branch -d'
alias gca='git commit --amend -C head'
alias gcc='git commit -C head'
alias gch='git checkout'
alias gchpl='gfa && gch origin/main pnpm-lock.yaml && pnpm i && gaa pnpm-lock.yaml'
alias gdc='git diff --cached'
alias gdn='gd --name-only'
alias gdn='git diff --name-only'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gl='git log'
alias glg='git log --graph --pretty=oneline --all --abbrev-commit'
alias gn='git checkout -b'
alias gp='git pull'
alias gpm='git pull origin main:main'
alias gpnpm='gchpl && gc -m "chore: checkout pnpm-lock from main and pnpm i"'
alias gpsh='git push'
alias gpsht='scb && git push origin "$current_branch_name":test'
alias gpu='scb && git push --set-upstream origin $current_branch_name'
alias gr='git reset'
alias grb='git rebase'
alias grbc='git rebase --continue'
alias grbcn='git rebase --continue --no-edit'
alias grbm='gpm && grb main'
alias grhh='scb && git reset --hard origin/$current_branch_name'
alias gs='git status'
alias gst='git stash'
alias gstk='git stash --keep-index'
