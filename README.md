# iperf-scripting
Bash wrapper for iperf to allow cluster network testing.

Dependencies:

* iperf
* screen
* password-less ssh onto all hosts

Both scripts output CSV to allow for further analysis.

##iperf.sh

Tests each link between a list of hosts one-by-one and bidirectionally (either bidirectional concurrent or consecutive)

Usage: iperf-test-script.sh <duration-seconds> <-r for consecutive birectional, -d for concurrent bidirectional> <output-format> (m for MBits, g for GBits) <network interface for monitoring> <host list space separated>

##iperf-multi.sh

Tests each path between a list of hosts fully simultaneously (n x n-1 connections at once)

Usage: iperf-multiway.sh <duration-seconds> <output-format> (m for MBits, g for GBits) <host list space separated>
