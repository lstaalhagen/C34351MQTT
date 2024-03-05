#!/usr/bin/env bash

# Check for root 
[ $(id -u) -ne 0 ] && echo "Script must be executed with sudo" && exit

# Create a mosquitto directory in /var/run for PID
[ ! -d /var/run/mosquitto ] && mkdir -p /var/run/mosquitto &&  chown mosquitto: /var/run/mosquitto

# Run clearnet just to be on the safe side
. /home/user/C34351MQTT/clearnet.sh

XTERMS="YES"
if [ "${1}" = "--nox" ]; then
  XTERMS="NO"
  shift
fi

# Start by creating the switch
ovs-vsctl add-br S1
if [ $? -ne 0 ]; then
  echo "Failed to add switch. Did you forget to run clearnet.sh after last time? Aborting ..."
  exit
fi 

NUMHOST=${1:-3}
NS=1
while [ $NS -le $NUMHOST ]; do
  # Create a namespace
  ip netns add "H${NS}"

  # Create a veth pair
  ip link add "veth${NS}1" type veth peer name "veth${NS}2"
  ip link set "veth${NS}2" netns "H${NS}"

  # Bring up
  ip netns exec "H${NS}" ip link set dev lo up
  ip netns exec "H${NS}" ip addr add "10.0.0.${NS}/8" dev "veth${NS}2"
  ip netns exec "H${NS}" ip link set dev "veth${NS}2" up
  ip link set dev "veth${NS}1" up

  # Attach to switch
  ovs-vsctl add-port S1 "veth${NS}1"

  # Open an xterm window on the host
  if [ "${XTERMS}" = "YES" ]; then
    ip netns exec "H${NS}" xterm -title "Host H${NS} (10.0.0.${NS})" &
  fi

  NS=$(($NS + 1))
done
ip link set S1 up
