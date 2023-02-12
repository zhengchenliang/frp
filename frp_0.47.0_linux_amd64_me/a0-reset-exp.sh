#!/bin/bash

#tar="/mnt/..."
#mpnsq=("wrk")

tar="/mnt/..."
mpnsq=("dir")

iic=0
for ii in ${mpnsq[*]}
do
  umount ${tar}/${ii}
  echo "Unmounted mount point ${tar}/${mpnsq[iic]}."
  let iic=iic+1
done

kill $(cat frpc_ssh.cur)
killall x11vnc







