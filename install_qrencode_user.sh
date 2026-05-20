#!/usr/bin/env bash
set -euo pipefail

PREFIX="$HOME/.local"
TMP_DIR="$HOME/qrencode_tmp"
mkdir -p "$PREFIX" "$TMP_DIR"
cd "$TMP_DIR"

wget -q --show-progress http://archive.ubuntu.com/ubuntu/pool/main/libp/libpng16/libpng16-16_1.6.43-1build1_amd64.deb
wget -q --show-progress http://archive.ubuntu.com/ubuntu/pool/universe/q/qrencode/libqrencode4_4.1.1-1_amd64.deb
wget -q --show-progress http://archive.ubuntu.com/ubuntu/pool/universe/q/qrencode/qrencode_4.1.1-1_amd64.deb

dpkg -x libpng16-16_1.6.43-1build1_amd64.deb "$PREFIX"
dpkg -x libqrencode4_4.1.1-1_amd64.deb "$PREFIX"
dpkg -x qrencode_4.1.1-1_amd64.deb "$PREFIX"

cd "$HOME"
rm -rf "$TMP_DIR"

grep -q 'export PATH="$HOME/.local/usr/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null || echo 'export PATH="$HOME/.local/usr/bin:$PATH"' >> "$HOME/.bashrc"
grep -q 'export LD_LIBRARY_PATH="$HOME/.local/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"' "$HOME/.bashrc" 2>/dev/null || echo 'export LD_LIBRARY_PATH="$HOME/.local/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"' >> "$HOME/.bashrc"

echo "qrencode installed under ~/.local. Run: source ~/.bashrc"
