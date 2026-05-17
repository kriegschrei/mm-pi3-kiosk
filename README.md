# MagicMirror Pi 3 Kiosk Setup

An optimized, highly stable kiosk configuration for deploying a **MagicMirror²** display client on a legacy Raspberry Pi 3. 

Because modern Chromium builds heavily stress the Pi 3's hardware acceleration—leading to overheating (~70°C+), thermal throttling, and SD card corruption—this setup forces full **Software Rendering** and bypasses the GPU entirely. It runs directly on a bare X-server (`xorg`) without the overhead of a desktop environment manager, maximizing system longevity and stability.

---

## Architecture Overview

* **Host System (Server):** Runs the MagicMirror² application inside a Docker container environment (e.g., behind Traefik).
* **Client System (Display Pi):** A minimal Raspberry Pi OS Lite setup that boots directly into an automated X-server context, launches Chromium with specialized software-only flags, and handles local power saving.

---

## One-Line Automated Installation

On a fresh installation of **Raspberry Pi OS Lite (64-bit)**, log in via SSH and execute the following command to download the repository bundle and run the installer automatically:

```bash
curl -sSL [https://raw.githubusercontent.com/kriegschrei/mm-pi3-kiosk/main/install.sh](https://raw.githubusercontent.com/kriegschrei/mm-pi3-kiosk/main/install.sh) | bash