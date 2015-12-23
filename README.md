# iperf-scripting
Bash wrapper for iperf to allow cluster network testing.

Dependencies:

* iperf (http://sourceforge.net/projects/iperf) - available from EPEL
* screen (http://www.gnu.org/software/screen)
* password-less ssh onto all hosts

Both scripts output CSV to allow for further analysis.

##iperf.sh

Tests each path between a list of hosts one by one in both directions (the directions can be tested at the same time or consecutively).

```
Usage: iperf-test-script.sh <duration-seconds> <-r for consecutive bidirectional, -d for concurrent bidirectional> <output-format> (m for MBits, g for GBits) <network interface for monitoring> <host list space separated>
```

Because this script was originally developed to detect scenarios in which frame errors occur on an interface, it also captures the number of frame errors that have occurred during the test execution, although of course this could be from other network traffic.

##iperf-multi.sh

Tests each path between a list of hosts fully simultaneously (n x n-1 connections at once). N.B. This test has the ability to completely saturate your network and therefore should be used with care, especially in production environments.

```
Usage: iperf-multiway.sh <duration-seconds> <output-format> (m for MBits, g for GBits) <host list space separated>
```

Note: Due to the time taken to establish the connections (and because the script doesn't do anything especially clever with regards to scheduling the start of each pathway) results for runs where duraction-seconds is relatively small (say 10-20 seconds) may not be accurate.
