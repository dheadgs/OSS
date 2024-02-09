#!/bin/sh
#      		      SMS_monitoring_module		        #
#        		by gedaskalakis            		#
#                                   				#
#  This is a sanity and monitoring script for the  sms module   #
#  		in KALI and mediation/curbas db		        #

#HOLMediationDBEventsInboundModule


script_path="/opt/curbas/scripts/tools/sms_monitor"
SMS_QUEUE_MAX_SIZE=2500
SMS_QUEUE_CURBAS_MAX_SIZE=3000
sms_queue_size="`${script_path}/mediation_db_sms_watcher.py`"
sms_queue_size_res=$?


echo "Current date is `date +"%d:%m:%Y %H:%M:%S"`"
echo "This script monitors the sms sent errors in /opt/provisioning/log/mediation_sms_log for smsSwitch module and querying mediationDB for the pending SMS, plus the SMS_QUEUE in curbasdb"
echo "So let's check..."


#Let's check how many SMS are pending in curbasDB first

countlist_curbas_sms=`echo "select count(id) from sms_queue where sent=0" | /usr/local/bin/dbgo | grep -vi connect | grep -v count | awk NF`

if [ ${countlist_curbas_sms} -lt ${SMS_QUEUE_CURBAS_MAX_SIZE} ]; then
	echo "No issue identified, sms_queue is less than $SMS_QUEUE_CURBAS_MAX_SIZE sms"
else
	echo "Something is wrong with SMS_QUEUE on curbas, let's inform the people"
	(echo -e "Current date is :\t`date +"%d:%m:%Y %H:%M:%S"`" ; echo -e "There is some queue in the SMS_QUEUE table at CurbasDB\n There are $countlist_curbas_sms pending SMS, check the state of SMS_QUEUE Table: \n \n select sent, from_unixtime(when_inserted_s)   from sms_queue  where sent=0 order by when_inserted_s")  |  mail -s "SMS MONITOR_CURBAS_QUEUE" georgios.daskalakis1@vodafone.com Georgios.Lamprinakos@vodafone.com  -c "DL-GR-PROVFIX@internal.vodafone.com, Smaragda.Georgakopoulou@vodafone.com"
	/opt/status/scripts/smppsender.sh -dest "6944700265" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist_curbas_sms pending SMS in curbasDB, check the issue!"
	/opt/status/scripts/smppsender.sh -dest "6944600060" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist_curbas_sms pending SMS in curbasDB, check the issue!"
fi


#Let's check polling errors and sms queue @ mediationDB now

tail -n 100  /opt/provisioning/log/mediation_sms_log/SMSdelivery.log | grep "Exception raised while sendins SMS"  1>"${script_path}/sms_monitor.log" 2>/dev/null
countlist=`tail -n 100 /opt/provisioning/log/mediation_sms_log/SMSdelivery.log | grep "Exception raised while sendins SMS" |  wc -l`

if [[ "x`cat "/opt/curbas/scripts/tools/sms_monitor//sms_monitor.log"`x" == "xx" &&  ${sms_queue_size} -lt ${SMS_QUEUE_MAX_SIZE} ]]; then
        echo -e "No errors found in smsSwitch and the pending SMS in the mediationDB are [  ${sms_queue_size}  ] which is below the current threshold. Exiting"
	exit 0;
elif 	
	[[ "x`cat "/opt/curbas/scripts/tools/sms_monitor//sms_monitor.log"`x" == "xx" && ${sms_queue_size} -ge ${SMS_QUEUE_MAX_SIZE} ]]; then
	( echo -e "Current date is: `date +"%d:%m:%Y %H:%M:%S"`"; echo "No errors found in smsSwitch in Curbas but $sms_queue_size pending SMS found in mediationDB which is above the threshold! Let's inform the people to restart the ESB module." ; echo -e "\n You have to restart the HOLSMSModule_v1_0_9App and HOLMediationDBEventsInboundModule  modules in PROD WPS!" ; echo -e "\nIT on Call has been informed.\n" ) |  mail -s "SMS MONITOR" Naveen.Palakuru@Vodafone.com Konstantina.Papanikolaou@vodafone.com georgios.galanos@vodafone.com Georgios.Lamprinakos@vodafone.com  -c "DL-GR-PROVFIX@internal.vodafone.com,  Smaragda.Georgakopoulou@vodafone.com, georgios.daskalakis1@vodafone.com"
	/opt/status/scripts/smppsender.sh -dest "6944700265" -message "`date +"%d:%m:%Y %H:%M:%S"`:There were $sms_queue_size  pending SMS in the sms module in mediationDB. You have to restart the HOLSMSModule_v1_0_9App module in PROD WPS!"
	/opt/status/scripts/smppsender.sh -dest "6944600060" -message "`date +"%d:%m:%Y %H:%M:%S"`:There were $sms_queue_size  pending SMS in the sms module in mediationDB. You have to restart the HOLSMSModule_v1_0_9App module in PROD WPS!"
	exit 0;
else 
	echo "Some errors found in the sms module in Curbas, let's try to automate the process"
	cat /opt/curbas/scripts/tools/sms_monitor/sms_monitor.log | cut -d']' -f2 | cut -d'[' -f2 | uniq 1>"${script_path}/sms_monitor_ids.log" 2>/dev/null
	cat ${script_path}/sms_monitor_ids.log |  awk '{printf("/usr/local/bin/dbexec curbas -sNe \"update sms_queue set sent=1 where id=%s  limit 15 \" \n", $1);}' | sh
fi

	
echo "Let's see if the automated process suceeded..."
countlist_db=`cat ${script_path}/sms_monitor_ids.log |  awk '{printf("/usr/local/bin/dbexec curbas -sNe \"select id from sms_queue  where id=%s and sent!=1 limit 15 \" \n", $1);}' | sh | wc -l`
threshold=0
countlist_uniq=`cat ${script_path}/sms_monitor_ids.log | wc -l`

if [ $countlist_db -eq $threshold ]; then
        echo "The automated process worked just fine, no actions needed! Exiting"
	(echo "Current date is :`date +"%d:%m:%Y %H:%M:%S"`" ; echo -e "The automated sanity process has worked!\n There were $countlist_uniq  errors in the sms module and the last $countlist_uniq  entries of them were: " ; cat /opt/curbas/scripts/tools/sms_monitor/sms_monitor.log  | tail -n $countlist_uniq ; echo -e "\nNo further actions needed.\n" ) |  mail -s "SMS MONITOR" georgios.daskalakis1@vodafone.com Georgios.Lamprinakos@vodafone.com  -c "panagiotis.katsanos1@vodafone.com, DL-GR-PROVFIX@internal.vodafone.com, DL-GR-CRMFIX@internal.vodafone.com, Smaragda.Georgakopoulou@vodafone.com"
        exit 2;
elif  [ $countlist_db -gt $threshold ]; then
	echo "Let's notify the people, the automated process has not worked"
	(echo -e "Current date is :\t`date +"%d:%m:%Y %H:%M:%S"`" ; echo -e "The automated process has not worked.\n There are $countlist_uniq  errors in the sms module and the last $countlist_uniq  entries are: " ; cat /opt/curbas/scripts/tools/sms_monitor/sms_monitor.log  | tail -n $countlist_uniq ; echo -e "\nYou need to restart the ESB module and clean the specific IDs from the curbas DB!!\n" ; echo -e "\nIT on call has been informed.\n") |  mail -s "SMS MONITOR" georgios.daskalakis1@vodafone.com Georgios.Lamprinakos@vodafone.com  -c "DL-GR-PROVFIX@internal.vodafone.com, DL-GR-CRMFIX@internal.vodafone.com, Smaragda.Georgakopoulou@vodafone.com"
	/opt/status/scripts/smppsender.sh -dest "6944700265" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist_uniq errors in the sms module, need to clean the errors"	
	/opt/status/scripts/smppsender.sh -dest "6944600060" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist_uniq errors in the sms module, need to clean the errors"
else
	echo "Something went wrong with the whole sanity process...let's notify the people anyway!"
	(echo -e "Current date is :\t`date +"%d:%m:%Y %H:%M:%S"`" ; echo -e "Something went wrong with the Sanity automated process...\n There are $countlist_db  errors in the sms module and the last two entries are: " ; cat /opt/curbas/scripts/tools/sms_monitor/sms_monitor.log  | tail -2 ; echo -e "\nYou need to restart the ESB module and clean the specific IDs from the curbas DB!!\n" ; echo -e "\nIT on call has been informed.\n") |  mail -s "SMS MONITOR" georgios.daskalakis1@vodafone.com Georgios.Lamprinakos@vodafone.com  -c "DL-GR-PROVFIX@internal.vodafone.com, DL-GR-CRMFIX@internal.vodafone.com, Smaragda.Georgakopoulou@vodafone.com"
	/opt/status/scripts/smppsender.sh -dest "6944700265" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist_uniq errors in the sms module, need to clean the errors"	
        /opt/status/scripts/smppsender.sh -dest "6944600060" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $countlist_uniq errors in the sms module, need to clean the errors"
fi

echo "Done"




















