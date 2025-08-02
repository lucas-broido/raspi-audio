# Raspberry Pi Bluetooth & Spotify Audio Receiver

This project turns your Raspberry Pi into a Bluetooth speaker and Spotify Connect receiver. It uses ALSA for audio output and sets up Raspotify and BlueZ for smooth streaming from Bluetooth and Spotify devices.

---

## ✅ Features

- 🔊 Play audio from **Bluetooth devices**
- 🎵 Stream from **Spotify Connect**
- 📦 Lightweight setup using `bluez-alsa` (no PulseAudio/GUI needed)
- 🎯 Automatically sets your preferred audio output device
- 🔁 Auto-starts services at boot

---

## 📋 Requirements

- Raspberry Pi with Raspberry Pi OS (Lite recommended)
- Internet connection for package installation
- Optional: USB sound card or other ALSA-supported audio output device

---

## 🛠️ What It Installs

- [`bluez`](https://packages.debian.org/search?keywords=bluez): Bluetooth stack
- [`bluez-alsa-utils`](https://github.com/Arkq/bluez-alsa): For Bluetooth audio via ALSA
- [`bluez-tools`](https://github.com/khvzak/bluez-tools): For managing Bluetooth devices
- [`pulseaudio` and `pulseaudio-module-bluetooth`](https://www.freedesktop.org/wiki/Software/PulseAudio/): Required by some audio services
- [`raspotify`](https://github.com/dtcooper/raspotify): Spotify Connect client

---

## 🚀 Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/lucas-broido/raspi-audio.git
   cd pi-audio-receiver
   ```

2. Make the script executable:
   ```bash
   chmod +x setup.sh
   ```

3. Run the setup:
   ```bash
   ./setup.sh
   ```

4. Follow the prompts:
   - Choose your audio card number (e.g. from a USB DAC)
   - Choose to install Bluetooth audio
   - Name your Spotify Connect device

5. Reboot your Pi:
   ```bash
   sudo reboot
   ```

---

## ⚙️ How It Works

### Bluetooth

- Installs and configures BlueZ + bluez-alsa for Bluetooth A2DP audio
- Sets up a custom `bt-agent` systemd service
- Configures auto-discoverability and reconnect behavior
- The bluetooth device name will be called the same as your Raspberry Pi host name

### Spotify

- Installs Raspotify
- Configures a friendly device name, high bitrate, and volume normalization
- Your Raspberry Pi will show up as a Spotify device when you open the app

### Audio Output

- Asks which audio card to use (`aplay -l`)
- Writes it to `/etc/asound.conf` using a helper script
- Ensures this runs on reboot using `cron`

---

## 🔄 Auto Configuration on Boot

Two cron jobs are added:

- `@reboot pulseaudio --start`
- `@reboot /usr/local/bin/set_card_num.sh` — ensures audio card stays consistent

---

## 🧪 Troubleshooting

- If audio doesn’t work, try:
  ```bash
  aplay -l
  sudo cat /etc/asound.conf
  sudo systemctl status bt-agent@hci0
  ```
- Check log output:
  ```bash
  journalctl -xe
  ```
- The bluetooth audio has a slight latency so this setup is suited for playing audio only and not watching videos


## 🙌 Credits

- [nicokaiser/rpi-audio-receiver](https://github.com/nicokaiser/rpi-audio-receiver)
- [dtcooper/raspotify](https://github.com/dtcooper/raspotify)
- [Arkq/bluez-alsa](https://github.com/Arkq/bluez-alsa)

