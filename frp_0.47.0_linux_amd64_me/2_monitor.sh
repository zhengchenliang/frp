#!/bin/bash

name=frps
timi=3600
pcur=$(cat ${name}.cur)
lcur=$(cat ${name}_log.cur)

while true; do
  tmp1=$(ps -e | grep $pcur | grep $name)
  if [[ -z $tmp1 ]]; then
    echo "$0: $pcur terminated before $(date +%Y.%m.%d_%T)." >> ${lcur}.log
    # kill same user other processes
    frpa1=($(ps -u | grep $name | grep -v grep | awk '{print $2}'))
    for ii1 in $frpa1; do
      kill -9 $ii1
    done
    # restart process
    source 1_openport.sh
    break
  fi
  echo "$0: $pcur running at $(date +%Y.%m.%d_%T)." >> ${lcur}.log
  sleep $timi
done
