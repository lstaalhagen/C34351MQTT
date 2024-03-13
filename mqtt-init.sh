#!/usr/bin/env bash

# Script to setup some things for the MQTT exercise in course 34351
# (C) Copyright 2024, Lars Staalhagen

# Check for root 
[ $(id -u) -ne 0 ] && echo "Script must be executed with sudo" && exit 1

# Create a mosquitto directory in /var/run for PID
[ ! -d /var/run/mosquitto ] && mkdir -p /var/run/mosquitto &&  chown mosquitto: /var/run/mosquitto

# Run clearnet just to be on the safe side
[ -s ./clearnet.sh ] && . ./clearnet.sh