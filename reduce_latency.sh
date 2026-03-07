#!/bin/bash

# Script to apply low-latency optimizations to existing Bluetooth audio setup
# Run this on your Raspberry Pi if you've already completed the initial setup

echo "🔧 Applying low-latency Bluetooth audio optimizations..."

# Update Bluetooth settings
echo "📝 Updating Bluetooth configuration..."
sudo tee /etc/bluetooth/main.conf >/dev/null <<'EOF'
[General]
Class = 0x200414
DiscoverableTimeout = 0
FastConnectable = true

[Policy]
AutoEnable=true
EOF

# PulseAudio configuration for lower latency
echo "📝 Configuring PulseAudio for low latency..."
sudo mkdir -p /etc/pulse
sudo tee -a /etc/pulse/daemon.conf >/dev/null <<'EOF'

# Low latency settings for Bluetooth audio
default-fragments = 2
default-fragment-size-msec = 5
resample-method = speex-float-1
enable-remixing = no
remixing-produce-lfe = no
remixing-consume-lfe = no
EOF

# Load Bluetooth module with lower latency
echo "📝 Configuring Bluetooth module parameters..."
sudo mkdir -p /etc/pulse/default.pa.d
sudo tee /etc/pulse/default.pa.d/bluetooth-latency.pa >/dev/null <<'EOF'
.ifexists module-bluetooth-discover.so
load-module module-bluetooth-discover a2dp_config="ldac_eqmid=hq ldac_fmt=f32 sbc_min_bp=53 sbc_max_bp=53"
.endif
EOF

# Restart services
echo "🔄 Restarting Bluetooth and audio services..."
sudo systemctl restart bluetooth
pulseaudio -k 2>/dev/null
pulseaudio --start

echo ""
echo "✅ Low-latency optimizations applied!"
echo ""
echo "📋 What this does:"
echo "   • Enables FastConnectable mode in BlueZ"
echo "   • Reduces PulseAudio buffer sizes to 5ms"
echo "   • Optimizes Bluetooth codec parameters"
echo "   • Expected latency: ~100-150ms (down from ~200-250ms)"
echo ""
echo "💡 For best results:"
echo "   • Reconnect your Bluetooth device"
echo "   • On Android: Enable low-latency SBC codec in Developer Options"
echo "   • Keep your device close to the Raspberry Pi"
echo ""
echo "Note: Some latency is inherent to Bluetooth A2DP."
echo "      For zero latency, use a wired connection."
