#!/bin/bash



streamer1=`ssh 10.120.161.12 -l root "echo 'select count(*) from service_request' | mysql -u root -pP@ssw0rd! -D actionstreamer | tail -n +2" | tail -1`
#streamer2=`ssh 10.120.161.13 -l root "echo 'select count(*) from service_request' | mysql -u root -pP@ssw0rd! -D actionstreamer | tail -n +2" | tail -1`
#streamer3=`ssh 10.120.161.14 -l root "echo 'select count(*) from service_request' | mysql -u root -proot -D actionstreamer_hol_general | tail -n +2" | tail -1`
streamer1_count=`ssh 10.120.161.12 -l root "echo 'select count(*) from service_request where status=0 and start_time > (NOW() - INTERVAL 15 MINUTE)' | mysql -u root -pP@ssw0rd! -D actionstreamer | tail -n +2"`
#streamer2_count=`ssh 10.120.161.13 -l root "echo 'select count(*) from service_request where status=0 and start_time > (NOW() - INTERVAL 15 MINUTE)' | mysql -u root -pP@ssw0rd! -D actionstreamer | tail -n +2"`
#streamer3_count=`ssh 10.120.161.14 -l root "echo 'select count(*) from service_request where status=0 and start_time > (NOW() - INTERVAL 15 MINUTE)' | mysql -u root -proot -D actionstreamer_hol_general | tail -n +2"`
streamer1_active=''
streamer2_active=''

proc_status=`ssh 10.120.161.12 -l root "crm_mon -1" | grep 'Started streamer' | awk '{print $4}'`
if [ "$proc_status" == "streamer1" ]; then
    streamer1_active='(Active)'
elif [ "$proc_status" == "streamer2" ]; then
    streamer2_active='(Active)'
fi

echo "streamer1 requests: $streamer1, pending: $streamer1_count $streamer1_active"
echo "streamer2 requests: $streamer2, pending: $streamer2_count $streamer2_active"
echo "streamer3 requests: $streamer3, pending: $streamer3_count"

