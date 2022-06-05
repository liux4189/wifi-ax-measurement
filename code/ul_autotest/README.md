# Uplink Multi-STA Test
## Description
![testbed](figures/uplink_testbed.png)

The codes in this repository are used for uplink iperf3 throughput measurement in a batch. The scheduler running on the desktop (192.168.50.101) can 1) configure the uplink MCS in both broadcom AP and AX200 clients; 2) configure iperf3 test paramtes on AX200 clients including the datarate and iperf3 server port); 3) trigger the iperf3 test by sending command to iperf3.c; 4) call wl command of AP to record the rx throughputs.
## Files
*iperf*

## Dependency
