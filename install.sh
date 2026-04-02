#!/bin/bash
# VCS Security — One-command installer
# Usage: curl -fsSL https://raw.githubusercontent.com/00peter0/vcs-server-releases/main/install.sh | bash

set -e

REPO="00peter0/vcs-server-releases"
INSTALL_DIR="/usr/local/bin"
DATA_DIR="/var/lib/vcs"
CONFIG_DIR="/etc/vcs"

echo "Installing VCS Security..."

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Download latest release
LATEST=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep tag_name | cut -d '"' -f4)
curl -fsSL "https://github.com/$REPO/releases/download/$LATEST/vcs-server-linux-$ARCH" -o "$INSTALL_DIR/vcs-server"
chmod +x "$INSTALL_DIR/vcs-server"

# Create directories
mkdir -p "$DATA_DIR" "$CONFIG_DIR"

# Install systemd service
cat > /etc/systemd/system/vcs-server.service << EOF
[Unit]
Description=VCS Security Server
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/vcs-server
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable vcs-server
systemctl start vcs-server

echo "VCS Security installed and running."
echo "Dashboard: https://your-tunnel-url"
