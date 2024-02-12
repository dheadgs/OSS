#!/bin/sh
#!/usr/bin/expect
#             			    # 
#   	 by gedaskalakis      	    #
#                                   # 
## Set the rfs threshold
rfs_threshold=25
script_path="/opt/curbas/scripts/tools/rfs"
error_threshold=50

echo "Checking the number of pending rfs..."
countlist=`/usr/local/bin/dbexec portability -sNe "select count(*) from parked_rfs where status!='completed'"`

#Let's back up the app_id's...
countlist_bak=`/usr/local/bin/dbexec portability -sNe "select app_id from parked_rfs where status!='completed'" |  sed 's/^/'\''/;s/$/'\'',/'`

echo -e  "During the run on the $(date +"%d:%m:%Y %H:%M:%S") the following app_id's have been found :\n$countlist_bak"  >> $script_path/rfs_app_id.bak 2>&1
#End of backing up the app_id's...

echo "Checking the number of errors in bizsmart module in provisioning..."
countlist_error=`ssh 10.120.161.100 -l "loginuser" " grep -c \"javax.xml.ws.WebServiceException: java.net.SocketTimeoutException: Async operation timed out\|Server was unable to process request\"  /opt/provisioning/log/elements_log/adapterslog/bizsmart_provisioning_inbound.log"`

echo "There are $countlist pending rfs and $countlist_error errors in provisioning, the date is $(date +"%d:%m:%Y %H:%M:%S")"  1>>"${script_path}/rfs.log" 2>/dev/null

if [[ $countlist -gt $rfs_threshold  &&  $countlist_error -gt $error_threshold ]]; then
        echo "Let's notify the people..."	
	#(echo "The pending rfs are $countlist and the number of errors in communication between bizsmart and provisioning are $countlist_error ... " ; cat /opt/curbas/scripts/tools/rfs/rfs.log | tail -2 ;  uuencode "/opt/curbas/scripts/tools/rfs/rfs.log" "/opt/curbas/scripts/tools/rfs/rfs.log") | sudo mail -s "RFS STATUS"  georgios.daskalakis1@vodafone.com -c panagiotis.katsanos1@vodafone.com
	(echo -e "The pending rfs are $countlist and the number of errors in communication between bizsmart and provisioning are $countlist_error ... \n " ; cat /opt/curbas/scripts/tools/rfs/rfs.log | tail -1) | mail -s "RFS STATUS"  georgios.daskalakis1@vodafone.com  -c "DL-GR-PROVFIX@internal.vodafone.com"
 	/opt/status/scripts/smppsender.sh -dest "6944700265" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist pending rfs and $countlist_error errors in provisioning, take some fuckin action"
	/opt/status/scripts/smppsender.sh -dest "6944600060" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist pending rfs and $countlist_error errors in provisioning, take some fuckin action"
       exit 1;
elif [ $countlist_error -gt $error_threshold ]; then
	echo "No errors found on the rfs module but $countlist_error found in holprovisioning, let's notify the people to check!"
	/opt/status/scripts/smppsender.sh -dest "6944700265" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist pending rfs and $countlist_error errors in provisioning, check BizSmart app for the NPR service!"
	/opt/status/scripts/smppsender.sh -dest "6944600060" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist pending rfs and $countlist_error errors in provisioning, check BizSmart app for the NPR service!"
else
       echo "No notification needed!"
       echo "Take care"
       exit 0
fi;
