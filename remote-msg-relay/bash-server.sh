#!/bin/bash

INPUT=input
OUTPUT=output

if [[ ! -p $INPUT ]]; then
	rm -f $INPUT
	mkfifo $INPUT
fi

if [[ ! -p $OUTPUT ]]; then
	rm -f $OUTPUT
	mkfifo $OUTPUT
fi

./remote-msg-rely.pl -i $INPUT -o $OUTPUT &
RELAY_PID=$!

control_c(){
	echo "Exiting..."
	kill $RELAY_PID
	exit $?
}

trap control_c SIGINT

state="unknown"

echo -e "AUTO this is autoreply" > $INPUT
sleep 10
echo -e "NOAUTO" > $INPUT

while true
do
	if ! read line < $OUTPUT; then
		echo "Failed to read"
		continue
	fi

	echo Server got: \"$line\"
	if [[ $line == "DISCONNECT "* ]]; then
		state="disconnected"
		continue
	elif [[ $line == "ERROR "* ]]; then
		state="error"
		continue
	elif [[ $line == "CONNECT "* ]]; then
		state="connected"
		continue
	fi

	if [ $state == "connected" ]; then
		echo "Acknowledge" > $INPUT
	fi
done

kill $RELAY_PID
