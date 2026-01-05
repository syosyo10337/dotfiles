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

## Cursor IDE Extensions

### 拡張機能のエクスポート（現在の環境から）

現在インストールされているCursor拡張機能のリストを保存します：

```bash
.bin/cursor-export-extensions.sh
```

このコマンドは `.cursor/extensions.txt` ファイルを生成します。変更をコミットしてください：

```bash
git add .cursor/extensions.txt
git commit -m "Update Cursor extensions list"
```

### 拡張機能のインストール（新しい環境へ）

新しい環境で同じ拡張機能をインストールします：

```bash
.bin/cursor-install-extensions.sh
```

インストール後、Cursorを再起動してください。

### 注意事項

- 拡張機能の実体（バイナリ）はリポジトリに含まれません
- `.cursor/extensions.txt` のみがバージョン管理されます
- これにより、リポジトリサイズを小さく保ちながら、環境間で拡張機能を同期できます

