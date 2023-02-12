#!/bin/bash

name=frps
pcur=$(cat ${name}.cur)
scur=$(cat ${name}_src.cur)

kill -9 $scur
kill -9 $pcur
