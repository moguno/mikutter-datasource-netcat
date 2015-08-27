#! /bin/sh

ping -t 1 -c 1 $1 > /dev/null 2>&1

if [ "$?" != 0 ];then
	echo "マスター大変！$1が死んでるよ！" | nc localhost 39390
fi
