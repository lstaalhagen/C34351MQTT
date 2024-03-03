#!/usr/bin/env bash

# Check for root 
[ $(id -u) -ne 0 ] && echo "Script must be executed with sudo" && exit

# Download MQTT broker and clients
apt-get update
apt-get -y install mosquitto mosquitto-clients

# Remove the autostart service of mosquitto
systemctl stop mosquitto.service
systemctl mask mosquitto.service

# Fix
sudo mkdir -p /var/run/mosquitto && sudo chown mosquitto: /var/run/mosquitto

# Set initial font for xterm
XRESOURCES=$HOME/.Xresources
touch $XRESOURCES
grep -q -E -e "^xterm*faceName" $XRESOURCES
if [ $? -ne 0 ]; then
   echo "xterm*faceName: Monospace" > $HOME/.Xresources
   echo "xterm*faceSize: 14" >> $HOME/.Xresources
   xrdb -merge $HOME/.Xresources
fi

echo -e "\n\n *** Please restart the Virtual Machine *** "


