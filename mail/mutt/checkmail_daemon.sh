#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
OFFLINEIMAP=/opt/local/bin/offlineimap
# full check every 5 minutes
INTERVAL=300

#trap "echo Mail daemon exting...;exit" SIGINT

last_full=$(date +%s)
while true; do
	$DIR/checkmail.py $OFFLINEIMAP $(( $INTERVAL / 3 ))
	curr_time=$(date +%s)
	diff=$(($curr_time - $last_full))
	#echo $diff
	if [[ $diff -gt $INTERVAL ]]; then
		echo "Full mail check" >&2
		$OFFLINEIMAP -u quiet -o
		last_full=$curr_time
	fi
	sleep 5
done

