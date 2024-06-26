# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# NVM path and autocompletion
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Updates PATH and enables shell command completion for the Google Cloud SDK
if [ -f '/Users/joelove/Projects/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/joelove/Projects/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/joelove/Projects/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/joelove/Projects/google-cloud-sdk/completion.zsh.inc'; fi

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
