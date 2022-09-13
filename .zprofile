# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# NVM path and autocompletion
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Updates PATH and enables shell command completion for the Google Cloud SDK
if [ -f '$HOME/Projects/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/Projects/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '$HOME/Projects/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/Projects/google-cloud-sdk/completion.zsh.inc'; fi

