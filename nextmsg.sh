#!/usr/bin/env bash

if [ ! -f .nextmsg ]; then
  echo "FMT=%Y%m%d-%H%M%S" > .nextmsg
  echo "VAL=0" >> .nextmsg
fi
. .nextmsg

if [ "${1}" = "-z" ]; then
  sed -i "s/VAL=.*/VAL=0/g" .nextmsg
  exit  
fi

NEWVAL=$((${VAL} + 1))
sed -i "s/VAL=.*/VAL=${NEWVAL}/g" .nextmsg
echo "$(date +${FMT}): Sequencenumber = ${NEWVAL}"
