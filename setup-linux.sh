#!/bin/sh
# Box-side install for the pi cloud dev environment. Runs from a dotfiles
# checkout on Amazon Linux: links the shared pi config and git-guard hooks,
# then fixes the gh credential helper for the Linux install path.
set -eu

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

sh "$DOTFILES/setup-pi.sh"

if command -v gh >/dev/null 2>&1; then
  gh_path="$(command -v gh)"
  git config --global credential.https://github.com.helper ""
  git config --global --add credential.https://github.com.helper "!$gh_path auth git-credential"
  git config --global credential.https://gist.github.com.helper ""
  git config --global --add credential.https://gist.github.com.helper "!$gh_path auth git-credential"
fi

echo "pi box dotfiles install complete"
