# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# NVM path and autocompletion
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


# Updates PATH and enables shell command completion for the Google Cloud SDK
if [ -f '/Users/joelove/Projects/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/joelove/Projects/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/joelove/Projects/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/joelove/Projects/google-cloud-sdk/completion.zsh.inc'; fi

# Use pyenv for Python version
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi