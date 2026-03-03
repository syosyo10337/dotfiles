#!/usr/bin/env bash
set -o pipefail

helpmsg() {
  command echo "Usage: $0 [--help | -h]" 0>&2
  command echo ""
}

link_to_homedir() {
  command echo "backup old dotfiles..."
  if [ ! -d "$HOME/.dotbackup" ];then
    command echo "$HOME/.dotbackup not found. Creating it..."
    command mkdir "$HOME/.dotbackup"
  fi

  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir=$(dirname ${script_dir})
  if [[ "$HOME" == "$dotdir" ]];then
    command echo "same install src dest"
    return
  fi

  for f in $dotdir/.??*; do
    # Skip directories that should not be symlinked
    [[ `basename $f` == ".git" ]] && continue
    [[ `basename $f` == ".bin" ]] && continue
    [[ `basename $f` == ".gitignore" ]] && continue
    [[ `basename $f` == ".vscode" ]] && continue
    
    if [[ -L "$HOME/`basename $f`" ]];then
      command rm -f "$HOME/`basename $f`"
    fi
    if [[ -e "$HOME/`basename $f`" ]];then
      command mv "$HOME/`basename $f`" "$HOME/.dotbackup"
    fi
    command ln -snf $f $HOME
  done
}

setup_gitconfig() {
  command echo "Setting up gitconfig..."
  
  # Check if .gitconfig.local already exists
  if [[ ! -e "$HOME/.gitconfig.local" ]]; then
    command echo "Creating ~/.gitconfig.local for personal settings..."
    command echo "Please enter your Git user information:"
    
    # Prompt for user name
    read -p "Your name: " git_user_name
    read -p "Your email: " git_user_email
    
    # Create .gitconfig.local
    cat > "$HOME/.gitconfig.local" << EOF
[user]
    name = ${git_user_name}
    email = ${git_user_email}

# Add other personal/machine-specific settings here
# [core]
#     excludesfile = ~/.gitignore_global
EOF
    
    command echo "✓ Created ~/.gitconfig.local"
  else
    command echo "✓ ~/.gitconfig.local already exists, skipping..."
  fi
}

while [ $# -gt 0 ];do
  case ${1} in
    --debug|-d)
      set -uex
      ;;
    --help|-h)
      helpmsg
      exit 1
      ;;
    *)
      ;;
  esac
  shift
done

link_to_homedir
setup_gitconfig
command echo -e "\e[1;36m Install completed!!!! \e[m"