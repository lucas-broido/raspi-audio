# From https://github.com/nicokaiser/rpi-audio-receiver/blob/main/install.sh
install_bluetooth() {
    read -p "Do you want to install Bluetooth audio (ALSA)? [y/n] " REPLY
    if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then return; fi

    # Bluetooth Audio ALSA Backend (bluez-alsa-utils)
    sudo apt update
    sudo apt install -y --no-install-recommends bluez-tools bluez-alsa-utils pulseaudio pulseaudio-module-bluetooth bluez

    # Bluetooth settings
    sudo tee /etc/bluetooth/main.conf >/dev/null <<'EOF'
[General]
Class = 0x200414
DiscoverableTimeout = 0

[Policy]
AutoEnable=true
EOF

    # Bluetooth Agent
    sudo tee /etc/systemd/system/bt-agent@.service >/dev/null <<'EOF'
[Unit]
Description=Bluetooth Agent
Requires=bluetooth.service
After=bluetooth.service

[Service]
ExecStartPre=/usr/bin/bluetoothctl discoverable on
ExecStartPre=/bin/hciconfig %I piscan
ExecStartPre=/bin/hciconfig %I sspmode 1
ExecStart=/usr/bin/bt-agent --capability=NoInputNoOutput
RestartSec=5
Restart=always
KillSignal=SIGUSR1

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable bt-agent@hci0.service

    # Bluetooth udev script
    sudo tee /usr/local/bin/bluetooth-udev >/dev/null <<'EOF'
#!/bin/bash
if [[ ! $NAME =~ ^\"([0-9A-F]{2}[:-]){5}([0-9A-F]{2})\"$ ]]; then exit 0; fi

action=$(expr "$ACTION" : "\([a-zA-Z]\+\).*")

if [ "$action" = "add" ]; then
    bluetoothctl discoverable off
    # disconnect wifi to prevent dropouts
    #ifconfig wlan0 down &
fi

if [ "$action" = "remove" ]; then
    # reenable wifi
    #ifconfig wlan0 up &
    bluetoothctl discoverable on
fi
EOF
    sudo chmod 755 /usr/local/bin/bluetooth-udev

    sudo tee /etc/udev/rules.d/99-bluetooth-udev.rules >/dev/null <<'EOF'
SUBSYSTEM=="input", GROUP="input", MODE="0660"
KERNEL=="input[0-9]*", RUN+="/usr/local/bin/bluetooth-udev"
EOF
}

# From https://github.com/nicokaiser/rpi-audio-receiver/blob/main/install.sh
install_raspotify() {
  read -p "Do you want to install Spotify audio? [y/n] " REPLY
  if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then return; fi

  read -p "What would you like to call your Spotify device? " device_name
  curl -sL https://dtcooper.github.io/raspotify/install.sh | sh
  sudo tee /etc/raspotify/conf >/dev/null <<EOF
LIBRESPOT_QUIET=on
LIBRESPOT_AUTOPLAY=on
LIBRESPOT_DISABLE_AUDIO_CACHE=on
LIBRESPOT_DISABLE_CREDENTIAL_CACHE=on
LIBRESPOT_ENABLE_VOLUME_NORMALISATION=on
LIBRESPOT_NAME="${device_name}"
LIBRESPOT_DEVICE_TYPE="avr"
LIBRESPOT_BITRATE="320"
LIBRESPOT_INITIAL_VOLUME="100"
EOF
}

set_default_device() {
  sound_device_name=$(aplay -l | grep -i "card $1" | grep -o '\[.*\],'| cut -c 2- | rev | cut -c 3- | rev)
  tmpfile=$(mktemp)
  sed -i '2d' set_card_num.sh
  awk -v var="$sound_device_name" 'NR==2{print "sound_device_name=\"" var "\""}1' set_card_num.sh > "$tmpfile" && mv "$tmpfile" set_card_num.sh

  sudo chmod +x set_card_num.sh
  ./set_card_num.sh 
}

add_cron_jobs() {
  crontab -l | grep -q '@reboot pulseaudio --start' || (crontab -l; echo '@reboot pulseaudio --start') | crontab -
  crontab -l | grep -q '@reboot ~/set_card_num.sh' || (crontab -l; echo '@reboot ~/set_card_num.sh') | crontab -
}

main() {

  sudo apt update && sudo apt upgrade -y
  aplay -l
  read -p "Which device card number would you like to use for audio output? " device_id

  set_default_device $device_id
  install_bluetooth
  add_cron_jobs
  install_raspotify
  
  echo "Setup complete. Please reboot your Raspberry Pi now."
}

main
