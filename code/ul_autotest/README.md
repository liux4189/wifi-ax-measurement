# Uplink Multi-STA Test
## Description
![testbed](figures/uplink_testbed.png)

The codes in this repository are used for uplink iperf3 throughput measurement in a batch. The scheduler running on the desktop (192.168.50.101) can 1) configure the uplink MCS in both broadcom AP and AX200 clients; 2) configure iperf3 test paramtes on AX200 clients including the datarate and iperf3 server port); 3) trigger the iperf3 test by sending command to iperf3.c; 4) call wl command of AP to record the rx throughputs.
## Files
1. *scheduler.c*: the scheduler of the experiment runs on the server PC.
2. *config.csv*:  configuration of the tests. 
3. *setup.sh*:
4. *iperf3.c*
5. *fixed_rate.h*
6. *rx_report.sh*

## Dependency
ubuntu 20.04, kernel 5.11.0-27-generic
iperf3.9 

## Working flow
![testbed](figures/flowchart.png)

## Usage
1. Run setup.sh on the server. The AP and all devices under test will be configured properly (including setup ssh key for passwordless acess and copy rx_report.sh script to AP). Note that depend on the devices to test, we might need to modify the variable IParray before running setup.sh. 
2. Edit the config.csv. Each row of config.csv specify on test.
