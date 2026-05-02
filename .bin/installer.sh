#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTDIR="$(dirname "${SCRIPT_DIR}")"

helpmsg() {
  echo "Usage: installer.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message"
  echo "  -d, --debug   Enable debug mode"
}

check_homebrew() {
  if command -v brew &> /dev/null; then
    echo "✓ Homebrew is already installed"
    return 0
  fi

  echo "Error: Homebrew is not installed."
  echo "Run the following command first:"
  echo ""
  echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  echo ""
  exit 1
}

link_to_homedir() {
  echo "Creating symlinks..."

  if [[ "$HOME" == "$DOTDIR" ]]; then
    echo "Error: dotfiles directory is the same as HOME"
    return 1
  fi

  if [ ! -d "$HOME/.dotbackup" ]; then
    mkdir "$HOME/.dotbackup"
  fi

  for f in "$DOTDIR"/.??*; do
    local name
    name=$(basename "$f")

    [[ "$name" == ".git" ]] && continue
    [[ "$name" == ".bin" ]] && continue
    [[ "$name" == ".gitignore" ]] && continue
    [[ "$name" == ".vscode" ]] && continue
    [[ "$name" == ".claude" ]] && continue

    if [[ -L "$HOME/$name" ]]; then
      rm -f "$HOME/$name"
    fi
    if [[ -e "$HOME/$name" ]]; then
      rm -rf "$HOME/.dotbackup/$name"
      mv "$HOME/$name" "$HOME/.dotbackup"
    fi
    ln -snf "$f" "$HOME"
    echo "  Linked: $name -> $f"
  done

  echo "✓ Symlinks created"
}

link_claude_settings() {
  read -p "Link Claude Code settings? (y/N): " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "✓ Skipping Claude Code settings"
    return 0
  fi

  echo "Linking Claude Code settings..."

  local src="$DOTDIR/.claude/settings.json"
  local dest_dir="$HOME/.claude"
  local dest="$dest_dir/settings.json"

  if [[ ! -f "$src" ]]; then
    echo "  Skip: $src not found"
    return 0
  fi

  if [[ -L "$dest_dir" ]]; then
    local target
    target="$(readlink "$dest_dir")"
    if [[ "$target" == "$DOTDIR/.claude" ]]; then
      echo "  Migrating legacy symlink: $dest_dir -> $target"
      rm -f "$dest_dir"
      mkdir -p "$dest_dir"
      shopt -s dotglob nullglob
      for entry in "$DOTDIR"/.claude/*; do
        local entry_name
        entry_name=$(basename "$entry")
        [[ "$entry_name" == "settings.json" ]] && continue
        mv "$entry" "$dest_dir/"
      done
      shopt -u dotglob nullglob
      echo "  Moved runtime state to $dest_dir"
    else
      rm -f "$dest_dir"
    fi
  fi

  mkdir -p "$dest_dir"

  if [[ -L "$dest" ]]; then
    rm -f "$dest"
  elif [[ -e "$dest" ]]; then
    rm -rf "$HOME/.dotbackup/.claude__settings.json"
    mv "$dest" "$HOME/.dotbackup/.claude__settings.json"
  fi
  ln -snf "$src" "$dest"
  echo "  Linked: $dest -> $src"
}

setup_gitconfig() {
  if [[ -e "$HOME/.gitconfig.local" ]]; then
    echo "✓ ~/.gitconfig.local already exists, skipping..."
    return 0
  fi

  echo "Creating ~/.gitconfig.local for personal settings..."
  read -p "Your name: " git_user_name
  read -p "Your email: " git_user_email

  cat > "$HOME/.gitconfig.local" << EOF
[user]
    name = ${git_user_name}
    email = ${git_user_email}
EOF

  echo "✓ Created ~/.gitconfig.local"
}

install_packages() {
  echo "Installing Homebrew packages..."
  brew bundle --file="$DOTDIR/Brewfile"
  echo "✓ Shared packages installed"

  if [[ -f "$DOTDIR/Brewfile.personal" ]]; then
    read -p "Install personal packages? (y/N): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      brew bundle --file="$DOTDIR/Brewfile.personal"
      echo "✓ Personal packages installed"
    fi
  fi
}

while [ $# -gt 0 ]; do
  case ${1} in
    --debug|-d)
      set -uex
      ;;
    --help|-h)
      helpmsg
      exit 0
      ;;
    *)
      ;;
  esac
  shift
done

check_homebrew
link_to_homedir
link_claude_settings
setup_gitconfig
install_packages
printf "\e[1;36m Install completed! \e[m\n"
