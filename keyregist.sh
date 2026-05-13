#!/bin/bash

# ==========================================================
# 【事前準備】qrencodeのインストール方法:
#
#  ■ macOSの場合 (Homebrewを使用):
#    brew install qrencode
#
#  ■ WSL (Ubuntu/Debian) の場合:
#    sudo apt update
#    sudo apt install qrencode
# ==========================================================

# --- 設定 ---
# ホスト名と現在日時を取得
HOSTNAME=$(hostname)
DATETIME=$(date +%Y%m%d_%H%M%S)

# ファイル名を「PC名_日時」の形式に設定
FILENAME="id_ed25519_${HOSTNAME}_${DATETIME}"
KEY_PATH="$HOME/.ssh/${FILENAME}"
COMMENT="${HOSTNAME}_${DATETIME}"

# 1. 鍵ペアの生成 (Ed25519)
# -f "$KEY_PATH": 指定したファイル名で保存
# -N "": パスフレーズなし
ssh-keygen -t ed25519 -C "$COMMENT" -f "$KEY_PATH" -N "" > /dev/null

echo "----------------------------------------------------------"
echo "鍵ペアの生成が完了しました。"
echo "保存先: $KEY_PATH"
echo "----------------------------------------------------------"

# 2. 公開鍵をQRコードで表示
if command -v qrencode > /dev/null; then
    echo "以下のQRコードをスキャンして公開鍵を取り出してください:"
    qrencode -t ansiutf8 -l L < "${KEY_PATH}.pub"
else
    echo "エラー: qrencode がインストールされていません。"
    echo "冒頭のコメントを参考にインストールしてください。"
fi

echo "----------------------------------------------------------"
echo "公開鍵の内容 (${FILENAME}.pub):"
cat "${KEY_PATH}.pub"
echo "----------------------------------------------------------"
