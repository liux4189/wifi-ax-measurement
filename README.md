# A First Look at Wi-Fi 6 in Action: Throughput, Latency, Energy Efficiency, and Security


## Setup
## Data
We collected three types of raw measurement data:
- .log: Throughput measurement log from ASUS router.
- .pcap: The wireshark capture using a Wi-Fi 6 sniffer.
- .csv:  The energy consumption trace of mobile devices captured by a power monitor.

### Name rules
The uplink and downlink files have slightly different naming rules. The downlink frame aggregation (AMPDU size) can be directly configured so the AMPDU configuration is specified in the file name. The name of downlink log follows:`{#USERS}{mu/su}_{#PC_NICS}pc_FA{#FRAME_AGGREGATED}_{BANDWITH}mhz_dl_mcs{MCS}_{PACKET_LENGTH}bytes.{log/pcap/csv}`. 
For example, 4su_4pc_FA3_dl_mcs3_4500bytes.log is captured in a downlink CSMA/CA test with 4 clients (all are PC users using AX210) and the 3 MPDUs aggregated to form a 4500-bytes AMPU.  In contrast, The uplink frame aggregation is indirectly configured using UL duration of OFDMA frame so the UL duration is specified in the file instead. The name of downlink log follows: `{#USERS}{mu/su}_{#PC_NICS}pc_{BANDWITH}mhz_ul_mcs{MCS}_{UL_DURATION}us.{log/pcap/csv}`.  For example, 4mu_4pc_80MHz_ul_mcs9_800us.log is a throughput log with UL duration configured to 800us. 

| Paramter     | Description           | Value |
| ------------- |:-------------:| -----|
| #USERS    | The number of users in the test |  1-8 |
| mu/su     | OFDMA or CSMA/CA      |  mu:OFDMA is turned on; su:OFDMA is turned off. |
| {#PC_NICS}pc | The number of PC user with Intel AX210    |  - |
|FA{#FRAME_AGGREGATED}| The number of MAC packet aggregated in AMPDU transmission |- |
|{BANDWITH}mhz| Bandwith setting | 20/40/80| 
|{PACKET_LENGTH}bytes| The aggregated packet length| -|
|{UL_DURATION}| Uplink duration of the OFDMA transmission| 0 - 4096 |







## MATLAB Script

