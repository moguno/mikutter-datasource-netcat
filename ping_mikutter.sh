#! /bin/sh

ping -t 3 -c 3 $1 > /dev/null 2>&1

result=$?

if [ "$result" != 0 ];then
	echo "マスター大変！$1が死んでるよ！" | nc localhost 39390
fi
