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
XRESOURCES=/home/user/.Xresources
touch $XRESOURCES
grep -q -E -e "^xterm*faceName" $XRESOURCES
if [ $? -ne 0 ]; then
   echo "xterm*faceName: Monospace" > $XRESOURCES
   echo "xterm*faceSize: 14" >> $XRESOURCES
   sudo -u user xrdb -merge $XRESOURCES
fi

# HACK GLOXBDITWPFR
grep -q -e "GLOXBDITWPFR" /root/.bashrc
if [ $? -ne 0 ]; then
  echo "# HACK GLOXBDITWPFR" >> /root/.bashrc
  echo "if [ ! -z \"$(ip netns identify)\" ]; then" >> /root/.bashrc
  echo "  export PS1=\"root@$(ip netns identify)# \"" >> /root/.bashrc
  echo "fi" >> /root/.bashrc
fi

echo -e "\n\n *** Please restart the Virtual Machine *** "
