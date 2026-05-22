ユーザー作成後

```bash
sudo apt update
sudo apt install -y build-essential pkg-config curl ca-certificates
bash ./install_qrencode_user.sh
bash ./keyregist.sh
```

鍵の登録依頼

依頼完了後

```bash
bash ./fetch_verification.sh
```
