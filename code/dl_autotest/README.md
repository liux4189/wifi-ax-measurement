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
*  *Server*  ~/workspace/ul_autotest/ directory has scheduler_dl.c, setup.sh, bs_data.sh, and config.csv  

2. Compile C programs.
   At the server, run
   ```gcc -o scheduler_dl scheduler_dl.c -lm```
   At each client, start a iperf3 server
   ```iperf3 -s```
   
3. Log into the admin page of AP and mode (e.g., OFDMA and CSMA/CA) 
4. Run setup.sh on the server. ```./setup.sh```` The AP and all devices under test will be configured properly (including setup ssh key for passwordless acess and copy rx_report.sh script to AP). Note that depend on the devices to test, we might need to modify the variable IParray before running setup.sh. 

5. Edit the config.csv. Each row of config.csv specify the seting of one test.
![config_csv](figures/config_csv.png)
*  addrPrefix. The subnet prefix of the Wi-Fi network.
*  cPort. The tcp port that the client program (iperf3_daemon.c) listen to for receiving control command from the scheduler. 
*  server. The suffix of the IP address of the server. 
*  clients. The list of suffix of the IP address of the clients, separated by "/"
*  sPorts.  The list of ports that iperf3 servers use. 
*  fixed_rate. Used to configure the MCS of clients. It is the input argument of fixed_rate.h
*  ul_ofdma_mcs. Used to configure the uplink ofdma MCS at the AP.
*  dataRate(mbps). Used to configure the iperf3 data rate.
*  devname.  The description of the client device in the test. This is only used to generate the name of Log files.
*  ofdma.  0: CSMA/CA 1:OFDMA. This is only used to generate the name of Log files.
*  duration(s). The duration of the test

6. Start the iperf3_daemon at the clients. They will start to wait for commands. 
   Alternatively, we can set iperf3_daemon to autostart on boot following [this](https://help.ubuntu.com/stable/ubuntu-help/startup-applications.html.en).
7. Open new terminals and start multiple iperf3 servers at the server. ```iperf3 -s -p PORT```  PORT needs to match the sPorts in the config.csv.
8. Start scheduler at the server. ```./sceduler config.csv```.
   After the test done, find the log files in the /tmp/home/root/measurement/M(S)U for OFDMA (CSMA/CA).
