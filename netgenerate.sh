#!/usr/bin/env bash

# Parse command line parameters
NUMHOSTS="3"
NOXTERMS="FALSE"
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      HELP="TRUE"
      shift
      ;;
    --noxterms)
      NOXTERMS="TRUE"
      shift
      ;;
    -n|--numhosts)
      NUMHOSTS="$2"
      shift
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

if [ ! -z "${HELP}" ]; then
  echo "Usage: "
  echo "   ${0} -h : Displays this message"
  echo " "
  echo "   ${0} [--noxterms] [-n|--numhosts N]"
  echo "      Creates virtual network with hosts connected to a switch. Unless the"
  echo "      '--noxterms' option is given, the script also opens an Xterm window"
  echo "      on each host. If the '-n' or '--numhosts' option is given, N hosts"
  echo "      are created; otherwise 3 hosts are created."
  exit
fi

# Check for root 
[ $(id -u) -ne 0 ] && echo "Script must be executed with sudo" && exit 1

# Create a mosquitto directory in /var/run for PID
[ ! -d /var/run/mosquitto ] && mkdir -p /var/run/mosquitto &&  chown mosquitto: /var/run/mosquitto

# Run clearnet just to be on the safe side
. /home/user/C34351MQTT/clearnet.sh

# Start by creating the switch
ovs-vsctl add-br S1
if [ $? -ne 0 ]; then
  echo "Failed to add switch. Did you forget to run clearnet.sh after last time? Aborting ..."
  exit
fi 

NS=1
while [ $NS -le $NUMHOSTS ]; do
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
  if [ "${NOXTERMS}" = "FALSE" ]; then
    ip netns exec "H${NS}" xterm -title "Host H${NS} (10.0.0.${NS})" &
  fi

  NS=$(($NS + 1))
done
ip link set S1 up
