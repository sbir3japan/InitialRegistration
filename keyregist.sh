#!/bin/bash

# =============================================================================
# SSH Key Generation & Auto GitHub Push Script
# 動作環境: WSL (Linux) / macOS
# =============================================================================

# 1. 変数の設定
REPO_URL="https://github.com/sbir3japan/WalletRegistration"
TEMP_DIR="WalletRegistration_tmp"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PC_NAME=$(hostname)
KEY_NAME="github_deploy_key_${PC_NAME}_${TIMESTAMP}"
OUTPUT_FILENAME="deploy_key_${PC_NAME}_${TIMESTAMP}.pub"

echo "--------------------------------------------------"
echo "🚀 鍵生成とリポジトリへの自動プッシュを開始します"
echo "💻 PC名: $PC_NAME"
echo "⏰ 日時: $TIMESTAMP"
echo "--------------------------------------------------"

# 2. SSH鍵の生成 (パスフレーズなし、コメントなし)
echo "🔑 SSH鍵を生成中..."
# 既存の鍵を上書きしないよう、タイムスタンプ付きのファイル名で生成
ssh-keygen -t ed25519 -f "$HOME/.ssh/$KEY_NAME" -N "" -C ""

if [ $? -eq 0 ]; then
    echo "✅ 鍵の生成に成功しました: $HOME/.ssh/$KEY_NAME"
else
    echo "❌ 鍵の生成に失敗しました"
    exit 1
fi

# 3. 管理用リポジトリのクローン
echo "📥 管理用リポジトリをクローン中..."
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi
git clone "$REPO_URL" "$TEMP_DIR"

if [ $? -ne 0 ]; then
    echo "❌ リポジトリのクローンに失敗しました。URLまたは権限を確認してください。"
    exit 1
fi

# 4. 公開鍵ファイルをリポジトリ内へコピー
echo "📄 公開鍵をリポジトリフォルダへ配置中..."
cp "$HOME/.ssh/${KEY_NAME}.pub" "$TEMP_DIR/$OUTPUT_FILENAME"

# 5. GitHubへ自動プッシュ
echo "📤 GitHubへプッシュを開始します..."
cd "$TEMP_DIR"

# Gitユーザー設定が未完了の場合のフォールバック (コミットのための一時設定)
if [ -z "$(git config user.name)" ]; then
    git config user.name "DeployKeyGenerator"
    git config user.email "registration@DeployKeyGenerator.com"
fi

git add "$OUTPUT_FILENAME"
git commit -m "Add deploy key for $PC_NAME at $TIMESTAMP"

# プッシュ実行 (HTTPS認証が必要な場合があります)
git push origin main

if [ $? -eq 0 ]; then
    echo "--------------------------------------------------"
    echo "✨ すべての工程が完了しました！"
    echo "✅ 公開鍵はリポジトリにプッシュされました。"
    echo "📂 公開鍵名: $OUTPUT_FILENAME"
    echo "--------------------------------------------------"
else
    echo "❌ プッシュに失敗しました。リポジトリが公開されているかを確認してください。"
    exit 1
fi
