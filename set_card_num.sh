#!/bin/bash
sound_device_name=""

# Find the card number of the Focusrite USB interface
CARD_NUM=$(aplay -l | grep -i "$sound_device_name" | head -n1 | sed -n 's/^card \([0-9]\+\):.*/\1/p')

# Check if a card was found
if [ -n "$CARD_NUM" ]; then
  echo "Setting ALSA defaults to card number: $CARD_NUM"

  sudo tee /etc/asound.conf >/dev/null <<EOF
defaults.pcm.card $CARD_NUM
defaults.ctl.card $CARD_NUM
EOF

else
  echo "⚠️  No USB audio device found! /etc/asound.conf not updated."
fi
