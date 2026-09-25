#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  worktree.sh ensure <repo>
  worktree.sh add <repo> <issue-id> <gitBranchName>
  worktree.sh remove <repo> <issue-id> [--force]
  worktree.sh list <repo>
  worktree.sh prune <repo>
  worktree.sh sweep <repo>
  worktree.sh sweep-all <workspace>
  worktree.sh cleanup-issue <workspace> <issue-id>
  worktree.sh preview <workspace> [<issue-id>|--clear] [--fresh] [--fresh-modules]
EOF
  exit 2
}

ensure_line() {
  local file="$1"
  local line="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -qxF "$line" "$file" || printf '%s\n' "$line" >>"$file"
}

remove_line() {
  local file="$1"
  local line="$2"
  local tmp
  [[ -f "$file" ]] || return 0
  tmp="$(mktemp)"
  grep -vxF "$line" "$file" >"$tmp" || true
  if [[ ! -s "$tmp" ]]; then
    rm -f "$file" "$tmp"
  else
    mv "$tmp" "$file"
  fi
}

# Primary repo root even when $1 is a linked worktree.
primary_root() {
  local common
  common="$(git -C "$1" rev-parse --path-format=absolute --git-common-dir)"
  dirname "$common"
}

issue_slug() {
  printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]'
}

is_default_branch() {
  [[ "$1" == "main" || "$1" == "master" ]]
}

is_helper_symlink() {
  local root="$1" dest="$2" path="$3" target
  target="$(readlink "$dest/$path" 2>/dev/null || true)"
  [[ -n "$target" && "$target" == "$root/$path" ]]
}

# Restore tracked files the helper replaced with symlinks into the primary checkout.
# Those typechanges are not unique work and they block a clean `worktree remove`.
restore_helper_symlinks() {
  local root="$1" dest="$2" line path
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    path="${line:3}"
    is_helper_symlink "$root" "$dest" "$path" || continue
    if git -C "$dest" ls-files --error-unmatch -- "$path" >/dev/null 2>&1; then
      git -C "$dest" restore -- "$path"
    else
      rm -f "$dest/$path"
    fi
  done < <(git -C "$dest" status --porcelain)
}

# Unique dirt only. Helper env symlinks do not count.
unique_porcelain() {
  local root="$1" dest="$2" line path
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    path="${line:3}"
    if is_helper_symlink "$root" "$dest" "$path"; then
      continue
    fi
    printf '%s\n' "$line"
  done < <(git -C "$dest" status --porcelain)
}

worktree_flags() {
  local root="$1" dest="$2" branch="$3"
  local flags=() unique helper
  if is_default_branch "$branch"; then
    flags+=("on-main")
  fi
  helper=""
  unique=""
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    path="${line:3}"
    if is_helper_symlink "$root" "$dest" "$path"; then
      helper=1
    else
      unique=1
    fi
  done < <(git -C "$dest" status --porcelain)
  if [[ -n "$unique" ]]; then
    flags+=("dirty")
  elif [[ -n "$helper" ]]; then
    flags+=("helper-dirt")
  else
    flags+=("clean")
  fi
  local IFS=','
  printf '%s' "${flags[*]}"
}

cmd_ensure() {
  local root
  root="$(primary_root "$1")"
  mkdir -p "$root/worktrees"
  ensure_line "$root/.git/info/exclude" "/worktrees/"
  # Indexing only: idle worktrees stay out of codebase search.
  # Never put /worktrees/ in .cursorignore: that blocks Read/Write/StrReplace.
  ensure_line "$root/.cursorindexingignore" "/worktrees/"
  ensure_line "$root/.git/info/exclude" ".cursorindexingignore"

  # Migrate the old hard-ignore. Leave a committed .cursorignore alone.
  if [[ -f "$root/.cursorignore" ]] \
    && ! git -C "$root" ls-files --error-unmatch .cursorignore >/dev/null 2>&1; then
    remove_line "$root/.cursorignore" "/worktrees/"
  fi
}

# Only gitignored local env files. Never replace a tracked file (.envrc,
# .env.cutover.example). The old `.env*` glob matched those and locked every
# worktree as dirty, which blocked cleanup.
symlink_env() {
  local root="$1"
  local dest="$2"
  local src base
  shopt -s nullglob
  for src in "$root"/.env "$root"/.env.[!.]* "$root"/.env.local "$root"/.env.*.local; do
    [[ -e "$src" ]] || continue
    base="$(basename "$src")"
    case "$base" in
      .env.example|.env.*.example|.envrc) continue ;;
    esac
    if git -C "$root" ls-files --error-unmatch -- "$base" >/dev/null 2>&1; then
      continue
    fi
    ln -sfn "$src" "$dest/$base"
  done
  shopt -u nullglob
}

cmd_add() {
  local repo="$1"
  local slug branch dest root held
  slug="$(issue_slug "$2")"
  branch="$3"
  if is_default_branch "$branch"; then
    echo "refusing to add a worktree on $branch: that locks the default branch in the primary checkout" >&2
    exit 1
  fi
  cmd_ensure "$repo"
  root="$(primary_root "$repo")"
  dest="$root/worktrees/$slug"

  if [[ -d "$dest" ]]; then
    held="$(git -C "$dest" rev-parse --abbrev-ref HEAD)"
    if is_default_branch "$held"; then
      if git -C "$dest" show-ref --verify --quiet "refs/heads/$branch"; then
        git -C "$dest" checkout "$branch"
      else
        echo "stale worktree on $held: $dest" >&2
        echo "remove it; never leave a worktree on $held" >&2
        exit 1
      fi
    fi
    printf 'reuse %s\n' "$dest"
    return 0
  fi

  git -C "$root" fetch origin
  if git -C "$root" show-ref --verify --quiet "refs/heads/$branch" \
    || git -C "$root" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git -C "$root" worktree add "$dest" "$branch"
  else
    git -C "$root" worktree add -b "$branch" "$dest" origin/main
  fi
  symlink_env "$root" "$dest"
  printf 'added %s\n' "$dest"
}

cmd_remove() {
  local repo="$1"
  local slug dest root force=0 unique
  slug="$(issue_slug "$2")"
  if [[ "${3:-}" == "--force" ]]; then
    force=1
  fi
  root="$(primary_root "$repo")"
  dest="$root/worktrees/$slug"

  if [[ ! -d "$dest" ]]; then
    printf 'missing %s\n' "$dest"
    return 0
  fi

  restore_helper_symlinks "$root" "$dest"
  unique="$(unique_porcelain "$root" "$dest")"

  if [[ "$force" -eq 0 && -n "$unique" ]]; then
    echo "worktree is dirty: $dest" >&2
    echo "$unique" >&2
    echo "commit, discard, or re-run with --force after the user asks" >&2
    exit 1
  fi

  if [[ "$force" -eq 1 ]]; then
    git -C "$root" worktree remove --force "$dest"
  else
    git -C "$root" worktree remove "$dest"
  fi
  printf 'removed %s\n' "$dest"
}

cmd_list() {
  git -C "$1" worktree list
}

cmd_prune() {
  git -C "$1" worktree prune
  git -C "$1" worktree list
}

# TSV: repo<TAB>issue<TAB>branch<TAB>flags<TAB>path
# flags: clean | helper-dirt | dirty, optionally prefixed with on-main,
emit_sweep_row() {
  local root="$1" dest="$2" repo_name branch slug flags
  [[ "$dest" == "$root" ]] && return 0
  [[ "$dest" == "$root/worktrees/"* ]] || return 0
  slug="$(basename "$dest")"
  branch="$(git -C "$dest" rev-parse --abbrev-ref HEAD)"
  flags="$(worktree_flags "$root" "$dest" "$branch")"
  repo_name="$(basename "$root")"
  printf '%s\t%s\t%s\t%s\t%s\n' "$repo_name" "$slug" "$branch" "$flags" "$dest"
}

cmd_sweep() {
  local root dest
  root="$(primary_root "$1")"
  while IFS= read -r dest; do
    [[ -n "$dest" ]] || continue
    emit_sweep_row "$root" "$dest"
  done < <(git -C "$root" worktree list --porcelain | awk '/^worktree / { print substr($0, 10) }')
}

cmd_sweep_all() {
  local workspace="$1" repo
  [[ -d "$workspace" ]] || {
    echo "not a directory: $workspace" >&2
    exit 1
  }
  for repo in "$workspace"/*; do
    [[ -e "$repo/.git" ]] || continue
    cmd_sweep "$repo"
  done
}

cmd_preview() {
  local workspace="$1" infra="" candidate
  shift
  for candidate in "$workspace"/*/bin/dev; do
    if [[ -x "$candidate" ]]; then
      infra="$candidate"
      break
    fi
  done
  [[ -n "$infra" ]] || {
    echo "missing an executable */bin/dev under $workspace" >&2
    exit 1
  }
  "$infra" use "$@"
}

cmd_cleanup_issue() {
  local workspace="$1" slug repo
  slug="$(issue_slug "$2")"
  [[ -d "$workspace" ]] || {
    echo "not a directory: $workspace" >&2
    exit 1
  }
  for repo in "$workspace"/*; do
    [[ -e "$repo/.git" ]] || continue
    [[ -d "$repo/worktrees/$slug" ]] || continue
    cmd_remove "$repo" "$slug"
  done
}

[[ $# -ge 2 ]] || usage
cmd="$1"
repo_or_workspace="$2"
shift 2

case "$cmd" in
  ensure) cmd_ensure "$repo_or_workspace" ;;
  add)
    [[ $# -ge 2 ]] || usage
    cmd_add "$repo_or_workspace" "$1" "$2"
    ;;
  remove)
    [[ $# -ge 1 ]] || usage
    cmd_remove "$repo_or_workspace" "$1" "${2:-}"
    ;;
  list) cmd_list "$repo_or_workspace" ;;
  prune) cmd_prune "$repo_or_workspace" ;;
  sweep) cmd_sweep "$repo_or_workspace" ;;
  sweep-all) cmd_sweep_all "$repo_or_workspace" ;;
  cleanup-issue)
    [[ $# -ge 1 ]] || usage
    cmd_cleanup_issue "$repo_or_workspace" "$1"
    ;;
  preview) cmd_preview "$repo_or_workspace" "$@" ;;
  *) usage ;;
esac
