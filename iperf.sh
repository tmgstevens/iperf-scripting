#!/bin/bash 
# -r is bidirectional bandwidth, whereas -d is simultaneous bidirectional bandwidth
if [[ "$#" -ne 5 ]] || [[ "$2" != "-r"  && "$2" != "-d" ]]; then
	echo "Usage: iperf.sh <duration-seconds> <-r for consecutive birectional, -d for concurrent bidirectional> <output-format> (m for MBits, g for GBits) <network interface for monitoring> ""<host list space separated>"""
	exit 1
fi

IPERF_OPTS="$2 -f $3 -t $1"
HOST_ARRAY=($5)
NW_IF=$4

#Write out CSV header
echo "Source Host, Dest Host,Throughput Up, Throughput Down, Frame Errors on Destination, Frame Errors on Source"

for ((FROMHOST=0;FROMHOST<${#HOST_ARRAY[@]};++FROMHOST))
do
	FROMHOSTNAME=${HOST_ARRAY[$FROMHOST]}
	ssh $FROMHOSTNAME "killall iperf" 2>/dev/null
	ssh $FROMHOSTNAME "screen -d -m iperf -s & " 2>/dev/null
	
	for ((TOHOST=0;TOHOST<${#HOST_ARRAY[@]};++TOHOST))
	do
		TOHOSTNAME=${HOST_ARRAY[$TOHOST]}

		if [ $FROMHOST -lt $TOHOST ]; then
			echo -n $FROMHOSTNAME,
			FRAME_ERRORS=$(ssh $FROMHOSTNAME "ifconfig $NW_IF | tr '\n' ' ' | grep -oh \"frame:[0-9]*\" | grep -o [0-9]*" 2>/dev/null) 
			ssh $TOHOSTNAME "echo -n \$HOSTNAME, && FRAME_ERRORS=\$(ifconfig $NW_IF | tr '\n' ' ' | grep -oh \"frame:[0-9]*\" | grep -o [0-9]*) && iperf -c $FROMHOSTNAME -f g $IPERF_OPTS | tr '\n' ' ' | grep -oh '[0-9\.]* [KMG]bits\/sec' | grep -oh '[0-9\.]*' | tr '\n' ',' && FRAME_ERRORS_DIFF=\$((\$(ifconfig $NW_IF | tr '\n' ' ' | grep -oh \"frame:[0-9]*\" | grep -o [0-9]*)-FRAME_ERRORS)) && echo -n \$FRAME_ERRORS_DIFF," 2>/dev/null
			FRAME_ERRORS_NEW=$(ssh $FROMHOSTNAME "ifconfig eth4 | tr '\n' ' ' | grep -oh \"frame:[0-9]*\" | grep -o [0-9]*" 2>/dev/null)
			echo $((FRAME_ERRORS_NEW-FRAME_ERRORS))
		fi
	done
	ssh  $FROMHOSTNAME "killall iperf" 2>/dev/null
done


