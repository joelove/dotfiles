#!/bin/sh
# Box-side install for the pi cloud dev environment. Runs from a dotfiles
# checkout on Amazon Linux: links the shared pi config and git-guard hooks,
# then fixes the gh credential helper for the Linux install path.
set -eu

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

sh "$DOTFILES/scripts/setup-pi.sh"

if command -v gh >/dev/null 2>&1; then
  gh_path="$(command -v gh)"
  # --replace-all makes this idempotent: a plain set fails once more than one
  # helper value exists, which happens after gh auth setup-git or a re-run.
  git config --global --replace-all credential.https://github.com.helper "!$gh_path auth git-credential"
  git config --global --replace-all credential.https://gist.github.com.helper "!$gh_path auth git-credential"
fi

# Box-only tmux config. The Mac keeps its own ~/.tmux.conf symlink, so this
# link lives here rather than in setup-pi.sh. A real file is backed up first.
if [ -e "$DOTFILES/.config/tmux/box.conf" ]; then
  if [ -e "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
    mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak-$(date +%s)"
  fi
  ln -sfn "$DOTFILES/.config/tmux/box.conf" "$HOME/.tmux.conf"
fi

echo "pi box dotfiles install complete"
