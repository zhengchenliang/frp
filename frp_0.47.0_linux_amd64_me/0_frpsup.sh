#!/bin/bash

name=frps

source 1_openport.sh &
src_pid=$!
echo "Source PID $src_pid for frp server."
echo $src_pid > ${name}_src.cur
