export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"
export RBENV_ROOT="$HOME/.rbenv"
export PATH="/usr/local/opt/mysql/bin:$PATH"

PS1='%F{green}[%n@%m %T]%F{reset_color} %.
%# '
export PATH="$PATH:$HOME/development/flutter/bin"
export PATH="$PATH:$HOME/Dev/flutter/bin"

# fnm
FNM_PATH="/Users/masanao/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/masanao/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi
eval "$(fnm env --use-on-cd --shell zsh)"

# bun completions
[ -s "/Users/masanao/.bun/_bun" ] && source "/Users/masanao/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"
[[ /opt/homebrew/bin/kubectl ]] && source <(kubectl completion zsh)


# aliases
alias dc='docker compose'
alias k='kubectl'