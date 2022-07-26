#!/bin/bash
ssh-keygen -t rsa
ssh-copy-id admin@192.168.50.1
IParray=(194 139 45 243 35 238 36 135)
i=0
while [ $i -lt 8 ]
do
ssh-copy-id lrf@192.168.50.${IParray[i]}
ssh-copy-id root@192.168.50.${IParray[i]}
i=$(($i+1))
done
#ssh-copy-id lrf@192.168.50.194
#ssh-copy-id root@192.168.50.194
ssh admin@192.168.50.1 mkdir /tmp/home/root/measurement
scp rx_report.sh bs_data.sh admin@192.168.50.1:/tmp/home/root/measurement
ssh admin@192.168.50.1 chmod a+x /tmp/home/root/measurement/rx_report.sh
ssh admin@192.168.50.1 chmod a+x /tmp/home/root/measurement/bs_data.sh
