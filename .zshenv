# macOS/launchd and Ghostty do not export a UTF-8 locale. Without one, tools
# that consult the locale (notably less, which mdcat's mdpick/mdless paginate
# through) render multibyte glyphs as <XX> instead of box-drawing characters.
if [ -z "${LANG:-}" ] || [ "${LANG}" = "C" ] || [ "${LANG}" = "POSIX" ]; then
  export LANG=en_US.UTF-8
fi
if [ -z "${LC_CTYPE:-}" ] || [ "${LC_CTYPE}" = "C" ] || [ "${LC_CTYPE}" = "POSIX" ]; then
  export LC_CTYPE=en_US.UTF-8
fi

# Local, offline speech recognition for pi-speech (pi-mobile's dictation
# extension). PI_SPEECH_STT_URL points it at the whisper.cpp server run by
# .config/whisper/com.joelove.whisper-server.plist; the key is a placeholder
# the local server does not check. This lives in .zshenv (not .zshrc) so every
# zsh, interactive or not, inherits it; .tmux.conf also seeds tmux's global
# environment. Without it, pi-speech falls back to Apple/OpenAI recognition.
export PI_SPEECH_STT_URL="http://127.0.0.1:8080"
export PI_SPEECH_STT_KEY="local"

[ -f "$HOME/.automations.sh" ] && source "$HOME/.automations.sh"
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

alias assume=". assume"
