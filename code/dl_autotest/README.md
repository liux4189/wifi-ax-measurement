# Downlink Multi-STA Test
## Description
![testbed](figures/uplink_testbed.png)

The codes in this repository are used for downlink iperf3 throughput measurement in a batch. The scheduler running on the desktop (192.168.50.101) can 1) configure the downlink MCS at broadcom AP 2) trigger the iperf3 test from the desktop to mulitple STA; 3) call wl command of AP to record the tx throughput. In addition, the traffic is monitored by tcpdump and dump into .pcap files.

## Files
1. *scheduler_dl.c*: the scheduler of the experiment runs on the desktop PC.
2. *config.csv*:  configuration of the tests. 
3. *setup.sh*:  set up passwordless ssh, create directory and deploy scripts at the AP 
4. *bs_data.sh*: script running on AP that log the tx throughput.

## Dependency
ubuntu 20.04, kernel 5.11.0-27-generic
iperf3.9 

## Working flow
![testbed](figures/flowchart.png)

## Usage
1. Deploy the test scripts on the desktop server.
 
   make sure that ~/workspace/ul_autotest/ directory has scheduler_dl.c, setup.sh, bs_data.sh, and config.csv  

2. Compile C programs.
   At the server, run
   ```gcc -o scheduler_dl scheduler_dl.c -lm```
   At each client, start a iperf3 server
   ```iperf3 -s```
   
3. Log into the admin page of AP and configure the mode (e.g., OFDMA and CSMA/CA) 

4. Run setup.sh on the server. ```./setup.sh```` The AP will be configured properly (including setup ssh key for passwordless acess and copy bs_data.sh script to AP). Note that depend on the devices to test, we might need to modify the variable IParray before running setup.sh. 

5. Edit the config.csv. Each row of config.csv specify the seting of one test.
![config_csv](figures/config_csv.png)
*  addrPrefix. The subnet prefix of the Wi-Fi network.
*  clients. The list of suffix of the IP address of the WiFi STAs, separated by "/"
*  5g_rate. Fixed downlink MCS at the AP.   
*  pktLen:  The packet length of iperf3. This will become the -l paramter of the iperf3
*  dataRate(mbps). Used to configure the total iperf3 data rate.
*  devname.  The description of the client device in the test. This is only used to generate the name of Log files.
*  ofdma.  0: CSMA/CA 1:OFDMA. This is only used to generate the name of Log files.
*  duration(s). The duration of the test

6. Start scheduler at the server. ```./sceduler_dl config.csv```.
   After the test done, find the log files in the /tmp/home/root/measurement/DL/M(S)U for OFDMA (CSMA/CA).

7. Start the auto tcpdump. ```./autocap TID```
   The TID is used for sepcify the TID of the client to be monitored in the OFDMA mode. 
   The value can be obtained by generated some uplink traffic and run ``` wl -i eth6  umsched``` at the AP. 
