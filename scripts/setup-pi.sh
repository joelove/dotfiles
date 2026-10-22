#!/bin/sh
# Link the pi agent config and the git-guard hooks from a dotfiles checkout
# into $HOME. Idempotent and safe on macOS and Linux: a real file or directory
# is moved to a timestamped backup before it is replaced with a symlink.
set -eu

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
PI_SRC="$DOTFILES/.pi/agent"
PI_DEST="$HOME/.pi/agent"

backup() {
  if [ -e "$1" ] && [ ! -L "$1" ]; then
    mv "$1" "$1.bak-$(date +%s)"
  fi
}

link() {
  _src="$1"
  _dest="$2"
  [ -e "$_src" ] || return 0
  backup "$_dest"
  mkdir -p "$(dirname "$_dest")"
  ln -sfn "$_src" "$_dest"
}

mkdir -p "$PI_DEST"
for entry in settings.json keybindings.json mcp.json AGENTS.md agents themes extensions; do
  link "$PI_SRC/$entry" "$PI_DEST/$entry"
done

# git config, ignore rules, and the git-guard hooks.
link "$DOTFILES/.config/git/config" "$HOME/.config/git/config"
link "$DOTFILES/.config/git/ignore" "$HOME/.config/git/ignore"
link "$DOTFILES/.config/git/hooks" "$HOME/.config/git/hooks"
chmod +x "$DOTFILES/.config/git/hooks/"* 2>/dev/null || true

echo "pi agent config and git hooks linked from $DOTFILES"
