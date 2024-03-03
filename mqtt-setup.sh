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

# Install nextmsg
install -m 0755 nextmsg /usr/local/bin

cp newhostname.sh mqtt.py /home/user

echo -e "\n\n *** Please restart the Virtual Machine *** "


