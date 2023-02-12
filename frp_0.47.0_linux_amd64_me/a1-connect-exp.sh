#!/bin/bash

vncp="5971"

#pas="..."
#usr="..."
#usa="z"
#hst="..."
#prt="22"
#chr="bash-4.2"
#tar="/mnt/..."
#mptsq=("/publicfs/...")
#mpnsq=("wrk")
#frpd="/wrk/frp/frp_0.47.0_linux_amd64"
#cmd1="cd work/frp/frp_0.47.0_linux_amd64; source 0_frpsup.sh"

pas="..."
usr="ubuntu"
hst="..."
prt="22"
chr="...ubuntu"
tar="/mnt/tencent"
mptsq=("/home/ubuntu")
mpnsq=("dir")
frpd="/dir/frp"
cmd1="cd frp; source 0_frpsup.sh"

rm -rf ${tar}
iic=0
for ii in ${mptsq[*]}
do
  mkdir -p ${tar}/${mpnsq[iic]}
  # sshfs ${usr}@${hst}:${ii} ${tar}/${mpnsq[iic]} -p ${prt} -o 'debug,LogLevel=DEBUG1' -o ssh_command='sshpass -p ${pas} ssh' -o cache=yes,allow_other
  # The above sshpass is not stable in shell script so use expect instead
  /usr/bin/expect << EOF
  spawn -ignore HUP sshfs -o reconnect ${usr}@${hst}:${ii} ${tar}/${mpnsq[iic]} -p ${prt}
  expect "ass"
  send "${pas}\r"
  interact
EOF
  echo "Account ${usr}@${hst}:${ii} connected at mount point ${tar}/${mpnsq[iic]}."
  let iic=iic+1
done

cp [0-9]*.sh $tar$frpd
cp *tmpl $tar$frpd

sleep 7

expect << EOF
  spawn -ignore HUP ssh -Y ${usr}@${hst} -p ${prt}
  expect "ass"
  send "${pas}\r"
  expect "${chr}"
  send "${cmd1}\r"
  interact
EOF

ssh_pid=$(ps -e | grep ? | grep -v grep \
  | grep -v sshfs | grep ssh | awk 'END {print $1}')
echo "SSH pid for frps is ${ssh_pid}."
echo $ssh_pid > frpc_ssh.cur

sleep 5

cp ${tar}${frpd}/*cur .
frp1=$(cat frps_frp.cur)
frp2=$(cat frps_vnc.cur)

cat frpc.ini_tmpl | sed "s:FRP1:${frp1}:g" | sed "s:FRP2:${frp2}:g" \
  | sed "s:VNCP:${vncp}:g" | sed "s:SRV1:${hst}:g" > frpc.ini

chmod +x frpc
nohup ./frpc -c frpc.ini > frpc.log 2>&1 &
cli_pid=$!
echo "FRP client pid is ${cli_pid}."

x11vnc -forever -nap -ncache 10 -shared -auth guess -repeat -rfbauth /root/.vnc/passwd -rfbport ${vncp} -display :0 &
vnc_pid=$!
echo "VNC server pid is ${vnc_pid}."
