#!/bin/zsh
# shellcheck shell=zsh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f "${HOME}/.p10k.zsh" ]] || source "${HOME}/.p10k.zsh"

export ZSH="${HOME}/.oh-my-zsh"

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

source "${ZSH}/oh-my-zsh.sh"

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
  eval "$("$(which mise)" activate zsh)"
fi

# Add PNPM to PATH
export PNPM_HOME="${HOME}/Library/pnpm"

case ":${PATH}:" in
  *":${PNPM_HOME}:"*) ;;
  *) export PATH="${PNPM_HOME}:${PATH}" ;;
esac

# Add Volta to PATH
export PATH="${VOLTA_HOME}/bin:${PATH}"

# Add global yarn packages to PATH
export PATH="${HOME}/.yarn/bin:${HOME}/.config/yarn/global/node_modules/.bin:${PATH}"

# Add local binaries to PATH
export PATH="/usr/local/bin:${PATH}"

# Add user binaries to PATH
export PATH="${HOME}/.local/bin:${PATH}"

# Add Node home directory modules to PATH
export PATH="${HOME}/node_modules/.bin:${PATH}"

# Add Make to PATH
export PATH="/opt/homebrew/opt/make/libexec/gnubin:${PATH}"

# Set default editors
export EDITOR="cursor"
export GIT_EDITOR="nvim"

# OUTPUT FORMATTING
# =================
bold=$(tput bold)
italic=$(tput sitm)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
orange=$(tput setaf 3)
purple=$(tput setaf 4)
cyan=$(tput setaf 6)

# Don't add delete history commands to ZSH history
zshaddhistory() {
  [[ $1 != 'dc '* ]]
}

# Delete a line from history by index, i.e. dc -2
dc () {
  if [ $# -lt 1 ]; then
    echo "${bold}Usage:${normal} ${funcstack[1]} [index=-10]"
    return 2
  fi

  local HISTORY_IGNORE="${(b)$(fc -ln "$1" "$1")}"
  fc -W
  fc -p "${HISTFILE}" "${HISTSIZE}" "${SAVEHIST}"
  print "Deleted '${green}${HISTORY_IGNORE}${normal}' from history."
}

# Find current branch name and export to current environment
set_current_branch() {
  if git ls-files > /dev/null 2>&1; then
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    export current_branch
  fi
}

# Push current branch to git remote main, defaulting to origin
gpshr() {
  local remote="${1:-origin}"
  set_current_branch

  if [[ "${current_branch}" == "main" ]]; then
    git push "${remote}" main
  else
    git push "${remote}" "${current_branch}:main"
  fi
}

# Murder something by port
die() {
  local port="${1:-3000}"
  local pid
  pid=$(lsof -n -i4TCP:"${port}" | grep -m 1 LISTEN | awk '{ print $2 }')
  kill -9 "${pid}"
}

# Shorthand for installing types for an NPM package
ty() {
  npm add -D "${@/#/@types/}"
}

# List recent Git branches
recent() {
  echo "${bold}Recent branches${normal}:"
  git for-each-ref --sort=-committerdate --count="${1:-10}" --format='%(refname:short)' refs/heads/
}

# Turn on or off local SSL proxy
proxy() {
  kill %?local-ssl-proxy || local-ssl-proxy --source "${1:-3010}" --target "${2:-3000}" --cert "${HOME}/localhost.pem" --key "${HOME}/localhost-key.pem" &
}

# List all terminal colors
colors() {
  for i in {0..255}; do
    print -Pn "%K{${i}}  %k%F{${i}}${(l:3::0:)i}%f " "${${(M)$((i%6)):#3}:+$'\n'}"
  done
}

get_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

ensure_gh_dependency() {
  if ! command -v gh > /dev/null 2>&1; then
    brew install gh
  fi

  gh auth status
}

deploy_workflow="manual-deploy-service.yml"
deploy_default_environment="testing"

# List all Github deployment actions (alias: ds)
deploy_status() {
  ensure_gh_dependency

  gh run list --workflow="${deploy_workflow}" --limit=20
}

# Manually deploy a single service (alias: d)
deploy() {
  if [ $# -lt 1 ]; then
    echo "${bold}Usage:${normal} ${funcstack[1]} [service] [environment=${deploy_default_environment}] [branch=current]"
    return 2
  fi

  ensure_gh_dependency

  local service="$1"
  local environment="${2:-${deploy_default_environment}}"
  local branch="${3:-$(get_current_branch)}"

  echo # /br
  echo "${bold}Deploying ${green}${service}${normal} to ${cyan}${environment}${normal} (${orange}${branch}${normal})"

  gh workflow run "${deploy_workflow}" -r "${branch}" -F environment-name="${environment}" -F ref="${branch}" -F package-name="${service}"
  sleep 3 # slow Github is slow
  gh run list -w "${deploy_workflow}" -L 1 --json "url" --jq ".[0].url" | xargs open
}

# Open a PR with an automatically formatted title
# Usage: pr [base=main] [branch=current]
pr() {
  local base="${1:-main}"
  local branch="${2:-$(get_current_branch)}"

  ensure_gh_dependency

  if [[ ${branch} =~ ^([a-zA-Z]+-[0-9]+)-([^$]+) ]]; then
    local issue
    local title
    issue=$(echo "${match[1]}" | tr '[:lower:]' '[:upper:]')
    title=${match[2]//-/ }

    gh pr new -d -t "[${issue}] ${title}" -B "${base}" -H "${branch}" -T "pull_request_template.md"
  else
    echo # /br
    echo "${bold}Automatic title requires branch name to be in format ${orange}[ISSUE]-[DESCRIPTION]${normal}"
    echo "${italic}Use cmd+shift+. to copy branch name from Linear issue${normal}"

    gh pr new -d -B "${base}" -H "${branch}" -T "pull_request_template.md"
  fi
}

# Recursively delete files by name
del() {
  local filename="$1"

  if [ -z "${filename}" ]; then
    echo "${bold}Usage:${normal} del [filename]"
    return 2
  fi

  find . -not -path "*/node_modules/*" -name "${filename}" -type f -delete
}

# Assume an AWS profile
assume_profile() {
  if [ $# -lt 1 ]; then
    echo "${bold}Usage:${normal} ${funcstack[1]} [profile_name]"
    return 2
  fi

  export AWS_PROFILE="$1"
  echo "Assumed profile: ${green}${AWS_PROFILE}${normal}"
}

# List all AWS profiles
list_profiles() {
  grep -E '^\[profile' "${HOME}/.aws/config" | sed -E 's/\[profile (.*)\]/\1/'
}

# general
alias v='vim'
alias vim='nvim'
alias r='recent'
alias cat='bat'
alias catp='bat -p'
alias d='deploy'
alias ds='deploy_status'
alias scb='set_current_branch'
alias code='cursor'
alias c='cursor'
alias assume='assume_profile'
alias a='assume'
alias profiles='list_profiles'
alias p='profiles'

# configs
alias zshrc="${EDITOR} ${HOME}/.zshrc"
alias zprofile="${EDITOR} ${HOME}/.zprofile"
alias yabairc="${EDITOR} ${HOME}/.yabairc"
alias skhdrc="${EDITOR} ${HOME}/.skhdrc"
alias karabinerrc="${EDITOR} ${HOME}/.config/karabiner/karabiner.json"
alias tmuxrc="${EDITOR} ${HOME}/.tmux.conf"
alias p10krc="${EDITOR} ${HOME}/.p10k.zsh"

# docker
alias dsa='docker stop "$(docker ps -q)"'
alias drm='docker rm -f "$(docker ps -a -q)"'
alias dvrm='docker volume rm "$(docker volume ls -q)"'
alias dpra='docker image prune -a'

# tmux
alias tma='tmux attach'
alias tmd='tmux detach'
alias tml='tmux list-panes -a -F "#{pane_tty} #{session_name}"'

# terraform
alias tf='terraform'
alias tfi='terraform init'
alias tff='terraform fmt -write=true -recursive'
alias tfv='terraform validate'
alias tfp='terraform plan'
alias tfa='terraform apply'

# ts
alias ts='npx ts-node'
alias tstr='rm -rf *.tsbuildinfo || true && pnpm tsc --generateTrace ./trace'
alias tsta='tstr || true && pnpm --package=@typescript/analyze-trace dlx analyze-trace ./trace'

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
alias gpsht='scb && git push origin "${current_branch}:test"'
alias gpu='scb && git push --set-upstream origin "${current_branch}"'
alias gr='git reset'
alias grb='git rebase'
alias grbc='git rebase --continue'
alias grbcn='git rebase --continue --no-edit'
alias grbm='gpm && grb main'
alias grhh='scb && git reset --hard "origin/${current_branch}"'
alias gs='git status'
alias gst='git stash'
alias gstk='git stash --keep-index'
