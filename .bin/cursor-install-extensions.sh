#!/bin/bash
# Cursor拡張機能を一括インストールするスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTDIR="$(dirname "$SCRIPT_DIR")"
EXTENSIONS_FILE="$DOTDIR/.cursor/extensions.txt"

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "❌ エラー: $EXTENSIONS_FILE が見つかりません"
    echo "   先に cursor-export-extensions.sh を実行してください"
    exit 1
fi

echo "🔍 Cursor拡張機能をインストールしています..."
echo "📦 $(wc -l < "$EXTENSIONS_FILE" | tr -d ' ') 個の拡張機能"
echo ""

# Cursorコマンドが利用可能か確認
if command -v cursor &> /dev/null; then
    INSTALL_CMD="cursor"
elif command -v code &> /dev/null; then
    echo "⚠️  'cursor'コマンドが見つかりません。'code'コマンドを使用します..."
    INSTALL_CMD="code"
else
    echo "❌ エラー: 'cursor'または'code'コマンドが見つかりません"
    echo "   Cursorを起動し、コマンドパレット(Cmd+Shift+P)から"
    echo "   'Shell Command: Install 'cursor' command in PATH'を実行してください"
    exit 1
fi

# 拡張機能を1つずつインストール
installed=0
skipped=0
failed=0

while IFS= read -r extension; do
    # 空行やコメントをスキップ
    [[ -z "$extension" || "$extension" =~ ^# ]] && continue
    
    echo "📥 インストール中: $extension"
    if $INSTALL_CMD --install-extension "$extension" --force; then
        ((installed++))
    else
        echo "⚠️  スキップまたは失敗: $extension"
        ((failed++))
    fi
done < "$EXTENSIONS_FILE"

echo ""
echo "✅ 完了!"
echo "   インストール済み: $installed"
if [ $failed -gt 0 ]; then
    echo "   失敗/スキップ: $failed"
fi
echo ""
echo "💡 Cursorを再起動して拡張機能を有効化してください"

