# A First Look at Wi-Fi 6 in Action: Throughput, Latency, Energy Efficiency, and Security


## Setup
## Data 
### The naming rules:
The naming rule of the log is as follows:`{#USERS}{mu/su}_{#PC_NICS}pc_FA{#FRAME_AGGREGATED}_{BANDWITH}mhz_{ul/dl}_mcs{MCS}_{PACKET_LENGTH}bytes.log`. For example, 4su_4pc_FA3_dl_mcs3_4500bytes.log is captured in a downlink CSMA/CA test with 4 clients (all are PC users using AX210) and the 3 MPDUs aggregated to form a 4500-bytes AMPU. 

| Paramter     | Description           | Value |
| ------------- |:-------------:| -----|
| #USERS    | The number of users in the test |  1-8 |
| mu/su     | OFDMA or CSMA/CA      |  mu:OFDMA is turned on; su:OFDMA is turned off. |
| {#PC_NICS}pc | The number of PC user with Intel AX210    |  - |
|FA{#FRAME_AGGREGATED}| The number of MAC packet aggregated in AMPDU transmission |- |
|{BANDWITH}mhz| Bandwith setting | 20/40/80| 
|{PACKET_LENGTH}bytes| The aggregated packet length| -|



Throughput measurement data (the throughput log in ASUS router) is placed under /throughput directory.




## MATLAB Script

