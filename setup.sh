#!/usr/bin/env bash
set -euo pipefail

ZSHRC="$HOME/.zshrc"

# このスクリプトのディレクトリを取得（リポジトリのルート）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 設定するコンテンツ（マーカーで囲む）
MARKER_START="# >>> vibe-in-iterm >>>"
MARKER_END="# <<< vibe-in-iterm <<<"

CONFIG_BLOCK="${MARKER_START}
vc() { ${SCRIPT_DIR}/vc \"\$@\"; }
${MARKER_END}"

# .zshrc が存在しない場合は作成
if [ ! -f "$ZSHRC" ]; then
  touch "$ZSHRC"
fi

# 既存の vibe-in-iterm 設定をチェック
if grep -q "$MARKER_START" "$ZSHRC"; then
  echo "[info] vibe-in-iterm 設定は既に存在します。更新します..."
  # 既存の設定ブロックを削除
  sed -i '' "/${MARKER_START}/,/${MARKER_END}/d" "$ZSHRC"
fi

# 末尾に改行がない場合は追加
if [ -s "$ZSHRC" ] && [ "$(tail -c1 "$ZSHRC" | wc -l)" -eq 0 ]; then
  echo "" >> "$ZSHRC"
fi

# 設定ブロックを追加
echo "$CONFIG_BLOCK" >> "$ZSHRC"

echo "[done] vibe-in-iterm 設定を ~/.zshrc に追加しました"
echo "[info] vc 関数が設定されました"
echo "[info] 反映するには以下を実行してください:"
echo "  source ~/.zshrc"
