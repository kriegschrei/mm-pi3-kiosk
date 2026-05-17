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

# 2. Resolve Local System Username and Environment
TARGET_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$TARGET_USER")

echo "[+] Target execution user identified as: $TARGET_USER"
echo "[+] Target system configuration root: $USER_HOME"
echo "---------------------------------------------------------"

# 3. Interactive Configuration Prompts
read -p "[?] Enter MagicMirror Hostname or IP [Default: k8sm01]: " MM_HOST
MM_HOST=${MM_HOST:-magicmirror}

read -p "[?] Enter MagicMirror Port [Default: 8080]: " MM_PORT
MM_PORT=${MM_PORT:-80}

echo "--> Target Mirror URL configured as: http://$MM_HOST:$MM_PORT"
echo "---------------------------------------------------------"

# 4. Update Package Indexes and System Dependencies
echo "[+] Synchronizing remote package repositories..."
apt-get update

echo "[+] Committing baseline kiosk dependency installations (X11, unclutter, xdotool, chromium)..."
apt-get install -y xorg xserver-xorg xinit unclutter xdotool chromium-browser sed

# 5. Build and Position 'start-kiosk.sh' Runtime Asset Dynamically
echo "[+] Assembling and positioning 'start-kiosk.sh' execution asset..."

cat << EOF > "$USER_HOME/start-kiosk.sh"
#!/bin/bash

# --- DISPLAY CONFIGURATION & POWER SAVING ---
xset s noblank
xset s off
xset -dpms

# Initialize automated pointer suppression loop after 5 seconds of physical hardware idle
unclutter -idle 5 -root &

# --- CHROMIUM CRASH RECOVERY PATTERNS ---
if [ -f ~/.config/chromium/Default/Preferences ]; then
    echo "[*] Active Chromium tracking parameters found. Pre-clearing diagnostic block states..."
    sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/Default/Preferences
    sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences
fi

# --- BROWSER EXECUTION CONTAINER LAYER ---
# Software rasterization flags forced to keep Pi 3 thermals stable
chromium-browser \\
    --kiosk \\
    --no-sandbox \\
    --autoplay-policy=no-user-gesture-required \\
    --check-for-update-interval=31536000 \\
    --disable-gpu \\
    --disable-software-rasterizer \\
    --disable-features=TranslateUI \\
    --disable-infobars \\
    --noerrdialogs \\
    --fast \\
    --fast-start \\
    http://$MM_HOST:$MM_PORT
EOF

# Apply explicit ownership and permission masks
chown "$TARGET_USER:$TARGET_USER" "$USER_HOME/start-kiosk.sh"
chmod +x "$USER_HOME/start-kiosk.sh"
echo "[+] 'start-kiosk.sh' successfully deployed and given execution permissions."

# 6. Build and Bind Systemd Service Module
echo "[+] Assembling system automation layer: /etc/systemd/system/kiosk.service..."

cat << EOF > /etc/systemd/system/kiosk.service
[Unit]
Description=MagicMirror Kiosk Application Service
After=network.target network-online.target systemd-time-wait-sync.service
Wants=network-online.target

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

# 7. Initialize Service State Loops
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