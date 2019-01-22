#!/bin/bash
# -r is bidirectional bandwidth, whereas -d is simultaneous bidirectional bandwidth
if [[ "$#" -ne 4 ]] || [[ "$2" != "-r"  && "$2" != "-d" ]]; then
        echo "Usage: iperf.sh <duration-seconds> <-r for consecutive birectional, -d for concurrent bidirectional> <output-format> (m for MBits, g for GBits) ""<host list space separated>"""
        exit 1
fi

IPERF_OPTS="$2 -f $3 -t $1"
HOST_ARRAY=($4)

#Write out CSV header
echo "Source Host, Dest Host,Throughput Up, Throughput Down"

for ((FROMHOST=0;FROMHOST<${#HOST_ARRAY[@]};++FROMHOST))
do
        FROMHOSTNAME=${HOST_ARRAY[$FROMHOST]}
        for ((TOHOST=0;TOHOST<${#HOST_ARRAY[@]};++TOHOST))
        do
                TOHOSTNAME=${HOST_ARRAY[$TOHOST]}

                if [ $FROMHOST -lt $TOHOST ]; then
                        ssh $FROMHOSTNAME "killall iperf" 2>/dev/null
                        ssh $FROMHOSTNAME "screen -d -m iperf -D -s & " 2>/dev/null

                        echo -n $FROMHOSTNAME,
                        ssh $TOHOSTNAME "killall iperf" 2> /dev/null
                        ssh $TOHOSTNAME "echo -n \$HOSTNAME, && iperf -c $FROMHOSTNAME -f g $IPERF_OPTS | tr '\n' ' ' | grep -oh '[0-9\.]* [KMG]bits\/sec' | grep -oh '[0-9\.]*' | tr '\n' ' '; echo"  #2>/dev/null
                fi
        done
        ssh  $FROMHOSTNAME "killall iperf" 2>/dev/null
done
