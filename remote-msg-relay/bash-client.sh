#!/bin/bash

ADDR="127.0.0.1"
PORT=9527
# XXX Declare 10 to be the file handle of the socket
#     I just don't want to use 'eval' for every operation on
#     the socket

# turn off stderr temporarily
exec 3>&2 2> /dev/null
# open a local tcp port
exec 10<>/dev/tcp/"$ADDR"/"$PORT" || {
	echo "Failed to connect to $ADDR $PORT"
	exit 1
}
# restore stderr
exec 2>&3

COUNT=0
echo -e "Start" >&10
while read line <&10; do
	if [ "$line" == "this is autoreply" ]; then
		sleep 5
		echo "FOR AUTOREPLAY $COUNT"
		echo -e "Client test $COUNT" >&10
		continue
	fi

	COUNT=$(($COUNT+1))
	if [ $COUNT -gt 3 ]; then
		break
	fi
	echo "Client test $COUNT"
	echo -e "Client test $COUNT" >&10
done

# close the file handle
exec 10<&-
exec 10>&-
