#!/bin/bash
# Cursor拡張機能リストをエクスポートするスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTDIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$DOTDIR/.cursor/extensions.txt"

echo "🔍 Cursorの拡張機能リストをエクスポートしています..."

# Cursorコマンドが利用可能か確認
if command -v cursor &> /dev/null; then
    cursor --list-extensions > "$OUTPUT_FILE"
    echo "✅ 拡張機能リストを保存しました: $OUTPUT_FILE"
    echo "📦 $(wc -l < "$OUTPUT_FILE" | tr -d ' ') 個の拡張機能"
elif command -v code &> /dev/null; then
    # Cursorコマンドがない場合はcodeコマンドを試す
    echo "⚠️  'cursor'コマンドが見つかりません。'code'コマンドを使用します..."
    code --list-extensions > "$OUTPUT_FILE"
    echo "✅ 拡張機能リストを保存しました: $OUTPUT_FILE"
    echo "📦 $(wc -l < "$OUTPUT_FILE" | tr -d ' ') 個の拡張機能"
else
    echo "❌ エラー: 'cursor'または'code'コマンドが見つかりません"
    echo "   Cursorを起動し、コマンドパレット(Cmd+Shift+P)から"
    echo "   'Shell Command: Install 'cursor' command in PATH'を実行してください"
    exit 1
fi

echo ""
echo "💡 このファイルをdotfilesリポジトリにコミットしてください:"
echo "   git add $OUTPUT_FILE"
echo "   git commit -m 'Update Cursor extensions list'"

