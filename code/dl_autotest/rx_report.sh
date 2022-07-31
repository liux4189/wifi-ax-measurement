#!/bin/sh
i=0
while [ $i -lt $1 ]
do wl -i eth6 rx_report;
i=$(($i+1))
sleep 1;
done
