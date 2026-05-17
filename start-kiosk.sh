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
chromium-browser \
    --kiosk \
    --no-sandbox \
    --autoplay-policy=no-user-gesture-required \
    --check-for-update-interval=31536000 \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-features=TranslateUI \
    --disable-infobars \
    --noerrdialogs \
    --fast \
    --fast-start \
    http://k8sm01:8080