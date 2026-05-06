# fnm (interactive shell ごとに multishell dir を作成するため毎回必要)
eval "$(fnm env --use-on-cd --shell zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

[[ -x /opt/homebrew/bin/kubectl ]] && source <(kubectl completion zsh)


# aliases
alias d='docker'
alias dc='docker compose'
alias g='git'
alias k='kubectl'
alias lzd='lazydocker'
alias lzg='lazygit'
alias cl='claude'


# starship
eval "$(starship init zsh)"

# eza / bat / zoxide
alias ls="eza --icons"
alias ll="eza -l --icons"
alias cat="bat"
eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# editor (nvim)
export EDITOR='nvim'
export VISUAL='nvim'
alias nv='nvim'
alias vim='nvim'   # muscle memory用
alias vi='nvim'    # muscle memory用

# machine-specific overrides (git 管理外。雛形は CLAUDE.md 参照)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

