#!/bin/bash

# ==============================================================================
# [使い方]
#   ./fetch_upgrade.sh <SSH鍵ファイル名>
#
# [実行例]
#   chmod +x fetch_upgrade.sh
#   ./fetch_upgrade.sh id_ed25519_SourceCode_<hostname>_<yyyymmdd_hhmmss>
#
# [概要]
#   指定したSSH鍵を使って、DonauWalletUpgrade リポジトリを取得します。
#   取得済みの場合は git pull --ff-only で更新します。
# ==============================================================================

# --- 0. 引数チェック ---
if [ -z "${1:-}" ]; then
    echo "Usage: $0 <SSH_KEY_FILENAME>"
    echo "例: $0 id_ed25519_SourceCode_<hostname>_<yyyymmdd_hhmmss>"
    exit 1
fi

SSH_KEY="$HOME/.ssh/$1"
REPO_URL="git@github.com:sbir3japan/DonauWalletUpgrade.git"
TARGET_DIR="./DonauWalletUpgrade_local"

# 鍵の存在確認
if [ ! -f "$SSH_KEY" ]; then
    echo "エラー: 鍵ファイルが見つかりません: $SSH_KEY"
    exit 1
fi

# git の存在確認
if ! command -v git > /dev/null 2>&1; then
    echo "エラー: git がインストールされていません。"
    echo "例: sudo apt update && sudo apt install -y git"
    exit 1
fi

# SSH鍵の権限を補正（失敗しても処理は続行）
chmod 600 "$SSH_KEY" 2>/dev/null || true

# 指定したデプロイキーを使用して git コマンドを実行する関数
run_git_with_key() {
    GIT_SSH_COMMAND="ssh -i \"$SSH_KEY\" -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new" \
    git "$@"
}

# --- 1. データの取得 ---
echo "GitHub から DonauWalletUpgrade を取得中..."

if [ -d "$TARGET_DIR/.git" ]; then
    echo "既存の取得先が見つかりました。最新化します: $TARGET_DIR"
    if run_git_with_key -C "$TARGET_DIR" pull --ff-only; then
        RESULT="updated"
    else
        echo "エラー: データの更新に失敗しました。鍵の権限またはリポジトリ権限を確認してください。"
        exit 1
    fi
else
    if [ -e "$TARGET_DIR" ] && [ "$(find "$TARGET_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | head -n 1)" ]; then
        echo "エラー: 取得先ディレクトリが空ではありません: $TARGET_DIR"
        echo "不要であれば削除または移動してから再実行してください。"
        exit 1
    fi

    if run_git_with_key clone "$REPO_URL" "$TARGET_DIR"; then
        RESULT="cloned"
    else
        echo "エラー: データの取得に失敗しました。鍵の権限またはリポジトリ権限を確認してください。"
        exit 1
    fi
fi

# --- 2. 結果確認 ---
echo "------------------------------------------------"
if [ "$RESULT" = "cloned" ]; then
    echo "成功: データを $TARGET_DIR に取得しました。"
else
    echo "成功: $TARGET_DIR を最新化しました。"
fi

echo "取得先の内容:"
ls -1 "$TARGET_DIR" 2>/dev/null || echo "（内容を表示できませんでした）"
