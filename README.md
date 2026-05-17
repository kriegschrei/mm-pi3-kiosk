Manual Repository Setup
If you prefer to clone the repository manually and execute the installation locally:

Bash
# 1. Clone the repository
git clone [https://github.com/kriegschrei/mm-pi3-kiosk.git](https://github.com/kriegschrei/mm-pi3-kiosk.git)
cd mm-pi3-kiosk

# 2. Make the scripts executable
chmod +x install.sh start-kiosk.sh

# 3. Run the installer
sudo ./install.sh
Included Component Specifications
1. Kiosk Shell Script (start-kiosk.sh)
Handles the X-server initialization, screen-blanking timeouts, pointer hiding (unclutter), safe state resets for Chromium crash recovery, and execution of the browser binary with direct command-line arguments to suppress hardware pipelines.

Bash
#!/bin/bash

# --- DISPLAY CONFIGURATION & POWER SAVING ---
# Suppress screen saver blanking cycles and force steady state frame preservation
xset s noblank
xset s off
xset -dpms

# Initialize automated pointer suppression loop after 5 seconds of physical hardware idle
unclutter -idle 5 -root &

# --- CHROMIUM CRASH RECOVERY PATTERNS ---
# Programmatically inject safe states into local Chromium tracking blocks. 
# This prevents browser alert banners from clipping the mirror UI if raw power lines drop.
if [ -f ~/.config/chromium/Default/Preferences ]; then
    echo "[*] Active Chromium tracking parameters found. Pre-clearing diagnostic block states..."
    sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/Default/Preferences
    sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences
fi

# --- BROWSER EXECUTION CONTAINER LAYER ---
# Fire standalone Chromium wrapper bypassing standard GPU pipelines to enforce software raster loops.
# This prevents memory crashes, hardware translation lockups, and core overheating spikes on Pi 3 processors.
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
    http://k8sm01:8080
2. Systemd Automation Profile (kiosk.service)
Monitors the execution layer. It handles multi-user target initialization, links the execution space to the primary virtual framebuffer (DISPLAY=:0), and enforces an aggressive automated restart loop if the browser process crashes or lags.

Ini, TOML
[Unit]
Description=MagicMirror Kiosk Application Service
After=network.target network-online.target systemd-time-wait-sync.service
Wants=network-online.target

[Service]
Type=simple
User=kriegschrei
Environment=DISPLAY=:0
ExecStart=/usr/bin/xinit /home/kriegschrei/start-kiosk.sh -- -nocursor
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
3. Installation Logic Script (install.sh)
Automates system provisioning by capturing local user boundaries, pulling apt package dependencies, mapping configuration paths, compiling the service block, and loading systemd targets dynamically.

Bash
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
    curl -sSL [https://raw.githubusercontent.com/kriegschrei/mm-pi3-kiosk/main/start-kiosk.sh](https://raw.githubusercontent.com/kriegschrei/mm-pi3-kiosk/main/start-kiosk.sh) -o "$USER_HOME/start-kiosk.sh"
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
User=\\$TARGET_USER
Environment=DISPLAY=:0
ExecStart=/usr/bin/xinit \\$USER_HOME/start-kiosk.sh -- -nocursor
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
echo "     Execution script localized to: \\$USER_HOME/start-kiosk.sh"
echo "     Systemd service initialized to default targets."
echo "     To initiate the display stack immediately, run:"
echo "     sudo systemctl start kiosk.service"
echo "========================================================="
Post-Install Optimization & Diagnostics
Temperature and Health Tracking
Because the CPU handles all rendering computations, monitoring performance margins is critical. Use the built-in system checks to read exact temperatures and verify whether your power supply or cooling solution is keeping the hardware out of throttled states:

Bash
# Check current core temperatures
vcgencmd measure_temp

# Check live hex bitmasks for under-voltage or thermal capping histories
vcgencmd get_throttled
"""

with open("README.txt", "w") as f:
f.write(full_markdown_content.strip())

print("README.txt successfully generated.")

Your TXT file formatted in markdown is ready
[file-tag: code-generated-file-0-1779056520531170872]

The instructions, architectural overview, and embedded asset code-blocks (`start-kiosk.sh`,
