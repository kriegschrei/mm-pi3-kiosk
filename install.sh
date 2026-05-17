#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================================="
echo " Starting MagicMirror Pi 3 Kiosk Deployment Script       "
echo "========================================================="

# 1. Check for Root Permissions
if [ "$EUID" -ne 0 ]; then
  echo "[!] Critical Error: This installation script must be executed with root privileges."
  echo "    Please re-run utilizing: sudo ./install.sh"
  exit 1
fi

# 2. Resolve Local System Username
TARGET_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$TARGET_USER")

echo "[+] Target execution user identified as: $TARGET_USER"
echo "[+] Target system configuration root: $USER_HOME"

# 3. Update Package Indexes and System Dependencies
echo "[+] Synchronizing remote package repositories..."
apt-get update

echo "[+] Committing baseline kiosk dependency installations (X11, unclutter, xdotool, chromium)..."
apt-get install -y xorg xserver-xorg xinit unclutter xdotool chromium-browser sed

# 4. Handle Runtime Kiosk Execution Script Positioning
echo "[+] Syncing and positioning local 'start-kiosk.sh' runtime execution asset..."
if [ -f "start-kiosk.sh" ]; then
    cp start-kiosk.sh "$USER_HOME/start-kiosk.sh"
else
    echo "[*] Download stream hook active: Retrieving start-kiosk.sh master file..."
    curl -sSL https://raw.githubusercontent.com/kriegschrei/mm-pi3-kiosk/main/start-kiosk.sh -o "$USER_HOME/start-kiosk.sh"
fi

# Apply explicit ownership and permission masks
chown "$TARGET_USER:$TARGET_USER" "$USER_HOME/start-kiosk.sh"
chmod +x "$USER_HOME/start-kiosk.sh"
echo "[+] 'start-kiosk.sh' successfully deployed and given execution permissions."

# 5. Build and Bind Systemd Service Module
echo "[+] Assembling system automation layer: /etc/systemd/system/kiosk.service..."

cat << EOF > /etc/systemd/system/kiosk.service
[Unit]
Description=MagicMirror Kiosk Application Service
After=network.target network-online.target systemd-time-wait-sync.service

[Service]
Type=simple
User=$TARGET_USER
Environment=DISPLAY=:0
ExecStart=/usr/bin/xinit $USER_HOME/start-kiosk.sh -- -nocursor
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 6. Initialize Service State Loops
echo "[+] Refreshing systemd engine configurations..."
systemctl daemon-reload

echo "[+] Activating kiosk.service system state persistent link..."
systemctl enable kiosk.service

echo "========================================================="
echo " System Configuration Deployment Terminated Successfully "
echo "========================================================="
echo "     Execution script localized to: $USER_HOME/start-kiosk.sh"
echo "     Systemd service initialized to default targets."
echo "     To initiate the display stack immediately, run:"
echo "     sudo systemctl start kiosk.service"
echo "========================================================="