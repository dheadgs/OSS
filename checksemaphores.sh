#!/bin/bash
#							#
#    Simple script to monitor python semaphores		#
#		by gedaskalakis				#
#							#
#							#
#							#

scriptpath="/opt/provisioning/etc/.pythonsemaphores/"
threshold=5
#let's count semaphores
count_sem=`/usr/bin/find $scriptpath \( -name ".*.Inte*"  -o -name ".*.Call*" \)  -type f -mmin +90 -print | wc -l` 
echo "Current date is: `date +"%d:%m:%Y %H:%M:%S"`"
echo "Count  of locked semaphores :$count_sem"


#date ; read -t 10 -p "Hit ENTER or wait ten seconds" ; date

while true; do
    read -t 5 -p "Do you wish to proceed with the deletion of semaphores if any?" yn
   case $yn in
        [Yy]* ) date; break;;
        [Nn]* ) exit;;
        * )  	echo "No answer (yes or no), we proceed to  checkings..."; break;;
    esac
done




if [ ${count_sem} -lt ${threshold} ]; then
	echo "No issue identified, semaphores are under $threshold"
	exit 0
else
	echo  "Count $count_sem is above setted threshold, let's inform the users and delete the old ones"
	(echo   "Count is $count_sem which  is above the setted threshold ($threshold) , script is going to delete all the semaphores prior of 1.5 hours.") | mail -aFrom:locatesemaphores@curbas.com  -s "Barrings Python Semaphores" georgios.daskalakis1@vodafone.com DL-GR-PROVFIX@internal.vodafone.com
	/opt/status/scripts/smppsender.sh -dest "6944700265" -message "`date +"%d:%m:%Y %H:%M:%S"`:There are $count_sem pending semaphores (prior of 1.5 hours)  which will be soon auto-deleted"
	/usr/bin/find $scriptpath \( -name ".*.Inte*"  -o -name ".*.Call*" \)  -type f -mmin +150 -print > $scriptpath/checksemaphores_uid.log 2>&1
	/usr/bin/find $scriptpath \( -name ".*.Inte*"  -o -name ".*.Call*" \)  -type f -mmin +150 -delete
	count_sem=`/usr/bin/find $scriptpath \( -name ".*.Inte*"  -o -name ".*.Call*" \)  -type f -mmin +150 -print | wc -l`
	echo "New count is $count_sem"
fi
