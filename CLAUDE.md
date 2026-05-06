# dotfiles

macOS 用の個人 dotfiles。

## デプロイ方式

`$HOME` 直下に **シンボリックリンク** を張る方式。`.bin/installer.sh` がエントリポイント。

- `.??*` で始まるトップレベルファイルを `$HOME` にリンク（blacklist: `.git` / `.bin` / `.gitignore` / `.vscode` / `.claude`）
- `.claude/settings.json` は個別リンク（installer 内で interactive prompt）
- 既存ファイルは `~/.dotbackup/` に退避してからリンク張り替え
- 個人情報は git 管理外: `~/.gitconfig.local` / `Brewfile.personal`

## 変更の反映

- **既存リンク先のファイル編集** → `$HOME` 側に即反映（symlink なので）
- **新しいトップレベル dotfile を追加** → `.bin/installer.sh` を再実行する必要あり
- **トップレベル dotfile を削除** → 削除側で `~/.<name>` の dangling symlink も `rm` する必要あり（installer は引き算をやらない）

## Commit 規約

- prefix: `chore:` / `refactor:` / `docs:` / `feat:` / `fix:`（コロン後にスペース）
- 本文: 日本語、why 重視（what は diff で読める）
- 直前コミット例:
  - `chore: 使われていない .bashrc を削除`
  - `docs: README から削除済みの .bashrc 行を除去`

## 運用上の落とし穴

- **dangling symlink**: リポからファイルを消すと `~/<file>` が壊れた symlink として残る。`rm ~/<file>` も必ずペアで行う
- **README と現実のズレ**: `README.md` の "What's Installed" 一覧は手動更新。トップレベル dotfile を増減したら同時に修正する
- **bash は使わない**: ログインシェルは zsh。bash 用 rc を中途半端に維持しない（壊れた一部だけ動く環境が一番混乱を招く）

## スコープ方針（このリポジトリに何を入れる / 入れない）

- **`Brewfile` / `Brewfile.personal` の境界**: **業務 / 個人で使い分ける**。会社用 PC で使用が禁止されているツール・GUI cask は `Brewfile.personal` 側に入れる。両環境で使うものは `Brewfile`
- **新しい CLI ツールの config**: 基本的にここで管理する（別マシンで再現したいため）。設定ファイルがトップレベル dotfile (`~/.foo`) なら直置き、`~/.config/foo/` 配下なら `.config/foo/` ディレクトリで管理（installer は `.config/` ごと symlink する）
- **機密情報** (api key, token, ssh key 等): 当然除外。git 管理外
- **machine-specific な設定** (PATH のハードコードパス、特定マシンでしか使わない alias 等): `~/.zshrc.local` に分離する。`.gitconfig.local` と同じ流儀
  - `.zshrc` 末尾で `[ -f ~/.zshrc.local ] && source ~/.zshrc.local` で読み込み
  - `~/.zshrc.local` 自体は git 管理外（`*.local` パターンで `.gitignore` 済み）
  - 例: Intel homebrew (`/usr/local`) に入れている特定パッケージの PATH、業務マシン側で禁止されているツール用設定 等
  - `.zprofile` で `typeset -U path PATH` を設定済みなので、`.zshrc.local` 内で `path=(... $path)` しても自動で重複排除される
