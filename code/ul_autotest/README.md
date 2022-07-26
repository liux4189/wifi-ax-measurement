# Uplink Multi-STA Test
## Description
![testbed](figures/uplink_testbed.png)

The codes in this repository are used for uplink iperf3 throughput measurement in a batch. The scheduler running on the desktop (192.168.50.101) can 1) configure the uplink MCS in both broadcom AP and AX200 clients; 2) configure iperf3 test paramtes on AX200 clients including the datarate and iperf3 server port); 3) trigger the iperf3 test by sending command to iperf3.c; 4) call wl command of AP to record the rx throughputs.
## Files
1.*scheduler.c*
2.*config.csv*
3.*setup.sh*
4.*iperf3.c*
5.*fixed_rate.h*
6.*rx_report.sh*

## Dependency
ubuntu 20.04, kernel 5.11.0-27-generic
iperf3.9 

## Working flow
![testbed](figures/flowchart.png)
