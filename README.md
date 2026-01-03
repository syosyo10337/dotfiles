# Dotfiles

Personal dotfiles for development environment setup.

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
.bin/installer.sh
```

The installer will:
1. Backup existing dotfiles to `~/.dotbackup`
2. Create symlinks from this repository to your home directory
3. Prompt you to set up your Git user information (name and email)
4. Create `~/.gitconfig.local` for personal Git settings

## What's Installed

- `.zshrc` - Zsh configuration
- `.gitconfig` - Shared Git configuration (aliases, colors, etc.)
- `~/.gitconfig.local` - Personal Git settings (not tracked in this repo)

