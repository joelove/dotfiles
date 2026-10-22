# macOS/launchd and Ghostty do not export a UTF-8 locale. Without one, tools
# that consult the locale (notably less, which mdcat's mdpick/mdless paginate
# through) render multibyte glyphs as <XX> instead of box-drawing characters.
if [ -z "${LANG:-}" ] || [ "${LANG}" = "C" ] || [ "${LANG}" = "POSIX" ]; then
  export LANG=en_US.UTF-8
fi
if [ -z "${LC_CTYPE:-}" ] || [ "${LC_CTYPE}" = "C" ] || [ "${LC_CTYPE}" = "POSIX" ]; then
  export LC_CTYPE=en_US.UTF-8
fi

[ -f "$HOME/.automations.sh" ] && source "$HOME/.automations.sh"
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

alias assume=". assume"
