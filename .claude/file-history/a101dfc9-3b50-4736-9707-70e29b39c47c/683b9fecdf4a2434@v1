export PATH="/usr/local/opt/mysql/bin:$PATH"

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
alias d='docker'
alias dc='docker compose'
alias g='git'
alias k='kubectl'
alias lzd='lazydocker'


# starship
eval "$(starship init zsh)"

# vim related
alias ls="eza --icons"
alias ll="eza -l --icons"
alias cat="bat"
eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
