#!/usr/bin/env bash

# Check for root 
[ $(id -u) -ne 0 ] && echo "Script must be executed with sudo" && exit
REALUSER=${SUDO_USER}
[ -z "${REALUSER}" ] && echo "Environment variable $SUDO_USER not set as expected" && exit

# Download MQTT broker and clients
echo "Downloading MQTT broker and clients"
apt-get update
apt-get -y install mosquitto mosquitto-clients

# Remove the autostart service of mosquitto
echo "Stopping the mosquitto service"
systemctl stop mosquitto.service
systemctl mask mosquitto.service

# Hack to get a better default font size in Xterm windows
XRESOURCES=/home/${REALUSER}/.Xresources
if [ -s $XRESOURCES ]; then
  grep -q -e "^xterm\*faceName:" $XRESOURCES
  if [ $? -ne 0 ]; then
    echo "xterm*faceName: Monospace" >> $XRESOURCES
    echo "xterm*faceSize: 14" >> $XRESOURCES
    sudo -u ${REALUSER} xrdb -merge $XRESOURCES
  fi
else
  echo "xterm*faceName: Monospace" > $XRESOURCES
  echo "xterm*faceSize: 14" >> $XRESOURCES
  sudo -u ${REALUSER} xrdb -merge $XRESOURCES
fi
chown ${REALUSER}: $XRESOURCES

# HACK GLOXBDITWPFR
grep -q -e "GLOXBDITWPFR" /root/.bashrc
if [ $? -ne 0 ]; then
  echo '# HACK GLOXBDITWPFR' >> /root/.bashrc
  echo 'if [ ! -z "$(ip netns identify)" ]; then' >> /root/.bashrc
  echo '  export PS1="$(ip netns identify):\w# "' >> /root/.bashrc
  echo 'fi' >> /root/.bashrc
fi

echo -e "\n\n *** Please restart the Virtual Machine *** "
