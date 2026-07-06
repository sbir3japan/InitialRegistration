ユーザー作成後

```bash
sudo apt update
sudo apt install -y build-essential pkg-config curl ca-certificates git
bash ./install_qrencode_user.sh
bash ./keyregist.sh
```

鍵の登録依頼

依頼完了後

```bash
# 検証結果取得用（VerifyScript 用の秘密鍵ファイル名を指定）
bash ./fetch_verification.sh id_ed25519_VerifyScript_<hostname>_<yyyymmdd_hhmmss>

# Upgrade取得用（SourceCode 用の秘密鍵ファイル名を指定）
bash ./fetch_upgrade.sh id_ed25519_SourceCode_<hostname>_<yyyymmdd_hhmmss>
```
