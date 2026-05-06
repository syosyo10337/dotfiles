
# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

eval "$(/opt/homebrew/bin/brew shellenv)"

# zsh の path/PATH array は連動する tied parameter。
# typeset -U で重複排除を有効化 (再 source / nested shell でも安全)。
typeset -U path PATH

# bun
export BUN_INSTALL="$HOME/.bun"

# 静的 PATH (login shell で 1 回だけ追加すれば充分)
path=(
  "$HOME/.local/bin"
  "$BUN_INSTALL/bin"
  $path
)
