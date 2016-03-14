#!/bin/bash
if [[ "$#" -ne 3 ]]; then
	echo "Usage: iperf-multiway.sh <duration-seconds> <output-format> (m for MBits, g for GBits) ""<host list space separated>"""
	exit 1
fi
TEST_DURATION=$1

IPERF_OPTS="-t $TEST_DURATION -f $2"
HOST_LIST=$3

#Write out CSV headers
echo "Source Host, Dest Host,Throughput"

# Go through all hosts, kill and residual iperfs and prepare the /tmp locations.
# Start up iperf -s on all hosts in a screen session
for FROMHOSTNAME in $HOST_LIST
do
	ssh $FROMHOSTNAME "killall iperf" 2>/dev/null
	ssh $FROMHOSTNAME 'rm -f /tmp/iperf_*' 2>/dev/null
	ssh $FROMHOSTNAME "screen -d -m iperf -s & " 2>/dev/null
done

# Loop through all permutations of hosts to create hosts (except to oneself)
for FROMHOSTNAME in $HOST_LIST
do
	for TOHOSTNAME in $HOST_LIST
	do
		if [ $FROMHOSTNAME != $TOHOSTNAME ]; then
			ssh $TOHOSTNAME "nohup iperf -c $FROMHOSTNAME $IPERF_OPTS > /tmp/iperf_$FROMHOSTNAME &" 2>/dev/null
		fi
	done
done

# Wait the duration of the test plus 5 seconds (error tolerance)
sleep $(($TEST_DURATION+5))

# Loop through all hosts destroying the iperf screens and also printing out the results from each.
# N.B. The results are written by the innermost loop above, not by the iperf servers (-s).
for FROMHOSTNAME in $HOST_LIST
do
	ssh $FROMHOSTNAME "killall iperf" 2>/dev/null
	ssh $FROMHOSTNAME 'for f in /tmp/iperf_*; do echo -n $(hostname -s)","; echo -n $f | grep -oP  "/tmp/iperf_\K(\S*)" | tr -d "\n"; echo -n ","; cat $f | grep -oh '\''[0-9\.]* [KMG]bits\/sec'\'' | grep -oh '\''[0-9\.]*'\''; done' 2>/dev/null
        SUM=$(ssh $FROMHOSTNAME 'for f in /tmp/iperf_*; do BANDWIDTH=$(grep -hoP "([0-9]{1,12})\s(?=[KMG]bits/sec)" $f); SUM=$((SUM + BANDWIDTH));done;  printf "%d\n" $SUM ' 2>/dev/null)
        printf 'Total %s %d\n' $FROMHOSTNAME $SUM
done
