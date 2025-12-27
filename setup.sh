#!/usr/bin/env bash
set -euo pipefail

ZSHRC="$HOME/.zshrc"
VC_FUNC='vc() { ./vc "$@"; }'

# .zshrc が存在しない場合は作成
if [ ! -f "$ZSHRC" ]; then
  touch "$ZSHRC"
fi

# 既存の vc 関数定義をチェック
if grep -q '^vc()' "$ZSHRC"; then
  # 全く同じ定義かチェック
  if grep -Fxq "$VC_FUNC" "$ZSHRC"; then
    echo "[info] vc 関数は既に設定済みです"
    exit 0
  else
    echo "[warn] 異なる vc 関数が既に定義されています。手動で確認してください:"
    grep -A1 '^vc()' "$ZSHRC" || true
    exit 1
  fi
fi

# 末尾に改行がない場合は追加
if [ -s "$ZSHRC" ] && [ "$(tail -c1 "$ZSHRC" | wc -l)" -eq 0 ]; then
  echo "" >> "$ZSHRC"
fi

# vc 関数を追加
echo "$VC_FUNC" >> "$ZSHRC"

echo "[done] vc 関数を ~/.zshrc に追加しました"
echo "[info] 反映するには以下を実行してください:"
echo "  source ~/.zshrc"
