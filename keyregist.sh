#!/bin/bash

# --- 設定 ---
HOSTNAME=$(hostname)
DATETIME=$(date +%Y%m%d_%H%M%S)

# 生成する鍵のリスト定義（用途名）
USAGE_TYPES=("VerifyScript" "SourceCode")

# この実行で生成を試みた鍵パスを記録する配列
GENERATED_KEY_PATHS=()
GENERATED_KEY_FILENAMES=()
GENERATED_KEY_USAGES=()

# qrencode インストール案内の関数
show_install_instruction() {
    echo "=========================================================="
    echo "エラー: qrencode がインストールされていません。"
    echo "以下のコマンドでインストールしてください："
    echo ""
    echo " ■ macOS (Homebrew):"
    echo "   brew install qrencode"
    echo ""
    echo " ■ WSL (Ubuntu/Debian):"
    echo "   sudo apt update && sudo apt install qrencode"
    echo "=========================================================="
}

# この実行で作成済み、または作成途中の鍵ペアを削除する関数
cleanup_generated_keys() {
    echo ""
    echo "エラー: SSH鍵の生成に失敗しました。作成済みの鍵を削除します。"

    for KEY_PATH in "${GENERATED_KEY_PATHS[@]}"; do
        rm -f "${KEY_PATH}" "${KEY_PATH}.pub"
        echo "削除しました: ${KEY_PATH} / ${KEY_PATH}.pub"
    done
}

echo "SSH鍵ペアの生成を開始します..."

# --- 1. 鍵ペアをすべて生成 ---
for USAGE in "${USAGE_TYPES[@]}"; do
    FILENAME="id_ed25519_${USAGE}_${HOSTNAME}_${DATETIME}"
    KEY_PATH="$HOME/.ssh/${FILENAME}"
    COMMENT="${USAGE}_${HOSTNAME}_${DATETIME}"

    # 失敗時に作成途中の鍵も削除できるよう、生成前に記録する
    GENERATED_KEY_PATHS+=("$KEY_PATH")
    GENERATED_KEY_FILENAMES+=("$FILENAME")
    GENERATED_KEY_USAGES+=("$USAGE")

    echo ""
    echo ">>> 用途: ${USAGE} 用の鍵を生成中..."

    if ! ssh-keygen -t ed25519 -C "$COMMENT" -f "$KEY_PATH" -N "" > /dev/null; then
        cleanup_generated_keys
        exit 1
    fi

    echo "保存先: $KEY_PATH"
done

# --- 2. すべての鍵生成に成功した後で、QRコードと公開鍵内容を表示 ---
echo ""
echo "すべての鍵生成に成功しました。公開鍵情報を表示します。"

for i in "${!GENERATED_KEY_PATHS[@]}"; do
    KEY_PATH="${GENERATED_KEY_PATHS[$i]}"
    FILENAME="${GENERATED_KEY_FILENAMES[$i]}"
    USAGE="${GENERATED_KEY_USAGES[$i]}"

    echo ""
    if command -v qrencode > /dev/null; then
        echo "[${USAGE}] 公開鍵QRコード:"
        qrencode -t ansiutf8 -l L < "${KEY_PATH}.pub"
    else
        show_install_instruction
    fi

    echo "----------------------------------------------------------"
    echo "[${USAGE}] 公開鍵の内容 (${FILENAME}.pub):"
    cat "${KEY_PATH}.pub"
    echo "----------------------------------------------------------"
done

echo "すべての鍵生成プロセスが完了しました。"
