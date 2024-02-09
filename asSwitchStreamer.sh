#!/bin/bash



proc_status=`ssh 10.120.161.12 -l root "crm_mon -1" | grep 'Started streamer' | awk '{print $4}'`

if [ "$proc_status" == "streamer1" ]; then
    echo "Activating: streamer2"
    ssh 10.120.161.12 -l root "crm_resource -M -r streamer_IP" &> /dev/null
elif [ "$proc_status" == "streamer2" ]; then
    echo "Activating: streamer1"
    ssh 10.120.161.12 -l root "crm_resource -U -r streamer_IP" &> /dev/null
fi

