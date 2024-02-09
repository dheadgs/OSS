#!/bin/bash



proc_status=`ssh 10.120.161.12 -l root "crm_mon -1" | grep 'Started streamer' | awk '{print $4}'`

if [ "$proc_status" == "streamer1" ]; then
    echo "Clearing: streamer2"
    remoteIP='10.120.161.13'
elif [ "$proc_status" == "streamer2" ]; then
    echo "Clearing: streamer1"
    remoteIP='10.120.161.12'
fi
echo $remoteIP

shutdowncount=`ssh $remoteIP -l root "grep 'Shutdown complete' /home/acts/jboss-4.2.2.GA/server/default/log/server.log | wc -l" | tail -1`
shutdownnow=$shutdowncount
ssh $remoteIP -l root "service actionstreamer stop" &> /dev/null
echo "  Stopping ActionStreamer..."
while [ "$shutdowncount" == "$shutdownnow" ]; do
    shutdownnow=`ssh $remoteIP -l root "grep 'Shutdown complete' /home/acts/jboss-4.2.2.GA/server/default/log/server.log | wc -l" | tail -1`
    sleep 2
done
echo "  Clearing DB.."
ssh $remoteIP -l root "echo 'truncate ODE_JOB' | mysql -u root -pP@ssw0rd! -D ode_rt" &> /dev/null
ssh $remoteIP -l root "echo 'drop table log_entry' | mysql -u root -pP@ssw0rd! -D actionstreamer" &> /dev/null
ssh $remoteIP -l root "echo 'drop table mml_command' | mysql -u root -pP@ssw0rd! -D actionstreamer" &> /dev/null
ssh $remoteIP -l root "echo 'drop table network_operation' | mysql -u root -pP@ssw0rd! -D actionstreamer" &> /dev/null
ssh $remoteIP -l root "echo 'drop table service_log_entry' | mysql -u root -pP@ssw0rd! -D actionstreamer" &> /dev/null
ssh $remoteIP -l root "echo 'drop table service_request' | mysql -u root -pP@ssw0rd! -D actionstreamer" &> /dev/null
ssh $remoteIP -l root "mysql -u root -pP@ssw0rd! -D actionstreamer < /home/acts/scripts/acts_db_audit.sql" &> /dev/null
ssh $remoteIP -l root "service actionstreamer start" &> /dev/null
echo "  Starting ActionStreamer..."
echo "http://$remoteIP:8080/acts"

