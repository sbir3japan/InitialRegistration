#!/bin/bash

# =============================================================================
# SSH Key Generation & Repository Export Script
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
echo "🚀 セットアップを開始します"
echo "💻 PC名: $PC_NAME"
echo "⏰ 日時: $TIMESTAMP"
echo "--------------------------------------------------"

# 2. SSH鍵の生成 (メールアドレスなし、パスフレーズなし)
echo "🔑 SSH鍵を生成中..."
ssh-keygen -t ed25519 -f "$HOME/.ssh/$KEY_NAME" -N "" -C ""

if [ $? -eq 0 ]; then
    echo "✅ 鍵の生成に成功しました: $HOME/.ssh/$KEY_NAME"
else
    echo "❌ 鍵の生成に失敗しました"
    exit 1
fi

# 3. リポジトリのクローン
echo "📥 リポジトリをクローン中..."
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi
git clone "$REPO_URL" "$TEMP_DIR"

# 4. 公開鍵ファイルをリポジトリ内へコピー
echo "📄 公開鍵をリポジトリ用ファイルとして出力中..."
cp "$HOME/.ssh/${KEY_NAME}.pub" "$TEMP_DIR/$OUTPUT_FILENAME"

# 5. 完了報告と次のステップ
echo "--------------------------------------------------"
echo "✨ 処理が完了しました"
echo "📂 出力ファイル: $TEMP_DIR/$OUTPUT_FILENAME"
echo "--------------------------------------------------"
echo "【次の手順】"
echo "1. 以下のコマンドで公開鍵の内容を表示し、GitHubのDeploy Keyに登録してください:"
echo "   cat $HOME/.ssh/${KEY_NAME}.pub"
echo ""
echo "2. 管理者に報告するため、リポジトリにファイルをコミット＆プッシュしてください:"
echo "   cd $TEMP_DIR"
echo "   git add $OUTPUT_FILENAME"
echo "   git commit -m \"Add deploy key for $PC_NAME at $TIMESTAMP\""
echo "   git push"
echo "--------------------------------------------------"
