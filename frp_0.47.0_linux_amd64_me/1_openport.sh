#!/bin/bash

name=frps
port=45237
toke=shabiwanyier

while true; do
  tmp1=$(netstat -lntu | grep $port)
  if [[ -z $tmp1 ]]; then
    # Configure the ini file
    cat ${name}.ini_tmpl | sed "s:PPPP:${port}:g" | sed "s:TTTT:${toke}:g" \
      > ${name}.ini
    # Start the frp server on the current port
    chmod +x ${name}
    log1=${name}_$(date +%Y.%m.%d_%T)
    nohup ./${name} -c ${name}.ini -p $port > ${log1}.log 2>&1 &
    # Extract the PID of the frp server process
    frp_pid=$!
    echo "frp server started on port $port with PID $frp_pid."
    echo $frp_pid > ${name}.cur
    echo $port > ${name}_frp.cur
    port2=$((port + 1))
    while true; do
      tmp2=$(netstat -lntu | grep $port2)
      if [[ -z $tmp2 ]]; then
        echo $port2 > ${name}_vnc.cur
        break
      fi
      ((port2++))
    done
    echo $log1 > ${name}_log.cur
    break
  else
    echo "Port $port is in use. Trying the next one."
  fi
  ((port++))
done

sleep 10
source 2_monitor.sh
