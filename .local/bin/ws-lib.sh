#!/usr/bin/env bash
#
# ws-lib.sh - shared helpers for the ws-* workspace tools. Source it, do not run
# it. Resolve the caller's own directory first so a symlinked script finds this
# file next to itself.

# ws_normalize_remote URL -> owner/repo, or nothing for a non-GitHub remote.
ws_normalize_remote() {
  local url="$1" slug=""
  case "$url" in
    git@github.com:*)       slug="${url#git@github.com:}" ;;
    ssh://git@github.com/*) slug="${url#ssh://git@github.com/}" ;;
    https://github.com/*)   slug="${url#https://github.com/}" ;;
    http://github.com/*)    slug="${url#http://github.com/}" ;;
    git://github.com/*)     slug="${url#git://github.com/}" ;;
    *) return 0 ;;
  esac
  slug="${slug%.git}"
  slug="${slug#/}"
  printf '%s' "$slug"
}

# ws_derive_context DIR -> KEY=value lines for DEV_CTX_DIR, DEV_CTX_WORKTREE,
# DEV_CTX_REPO and DEV_CTX_BRANCH (the root is supplied by the caller).
ws_derive_context() {
  local dir toplevel branch remote repo
  dir=$(cd "$1" 2>/dev/null && pwd -P) || return 1
  printf 'DEV_CTX_DIR=%s\n' "$dir"
  toplevel=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)
  if [ -n "$toplevel" ]; then
    branch=$(git -C "$toplevel" symbolic-ref --quiet --short HEAD 2>/dev/null || true)
    [ -n "$branch" ] || branch="(detached $(git -C "$toplevel" rev-parse --short HEAD 2>/dev/null))"
    remote=$(git -C "$toplevel" remote get-url origin 2>/dev/null || true)
    repo=$(ws_normalize_remote "$remote")
    printf 'DEV_CTX_WORKTREE=%s\n' "$toplevel"
    printf 'DEV_CTX_REPO=%s\n' "$repo"
    printf 'DEV_CTX_BRANCH=%s\n' "$branch"
  else
    printf 'DEV_CTX_WORKTREE=\n'
    printf 'DEV_CTX_REPO=\n'
    printf 'DEV_CTX_BRANCH=\n'
  fi
}
