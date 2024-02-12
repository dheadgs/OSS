#!/bin/bash
####################################################
#						   #
#						   #
#	This is a simple  script to monitor        #
#	Contacts and Discounts dbTable @ curbas    #
#	in order to truncate data by gedaskalakis  #
#					           #
#						   #
#					           #
#						   #
####################################################


script_path="/opt/curbas/scripts/tools/MonitorScripts"
threshold=4000
daystocheck=180
email_recipients="georgios.daskalakis1@vodafone.com Georgios.Lamprinakos@vodafone.com aris.kostoulas@vodafone.com georgios.galanos@vodafone.com"
errpath="/root"

#Let's count garbage data for a six months period of time
count=`echo "select count(*) from contractsAndDiscounts WHERE status = 'initial' and billing_processed = 'N' AND (DATE_ADD(if(isnull(received_date), NOW(),received_date),INTERVAL $daystocheck DAY) < NOW())" | /usr/local/bin/dbgo | grep -iv connect | awk NF | grep -iv count`

echo -e "This script will check contractsAndDiscounts dbTable @ curbasdb schema in order to truncate data\nDate is `date +"%d:%m:%Y %H:%M:%S"`, so let's check"

if [ $count -gt $threshold ]; then
	echo -e "Threshold of $threshold has been reached (\"There are $count cases to be truncated\") , truncating the data in contractsAndDiscounts.\nLet's inform the people : $email_recipients."
	(echo -e "Threshold of $threshold has been reached (\"There are $count cases to be truncated\") , truncating the data in contractsAndDiscounts.\n\nCheck $errpath/ContractsAndDiscountsProcessor_err for more details") | mail -aFrom:truncateBilling@curbas.gr -s "contractsAndDiscounts Data" $email_recipients
	echo "UPDATE contractsAndDiscounts SET status='cancelled' WHERE status = 'initial' and billing_processed = 'N' AND (DATE_ADD(if(isnull(received_date), NOW(),received_date),INTERVAL $daystocheck DAY) < NOW()) limit 5001" | /usr/local/bin/dbgo 
else
	echo "No data to be truncated identifed (count is $count) , proceeding to stderr checking..."
fi

#Let's check "ContractsAndDiscountsProcessor_err" for any exceptions
echo "Let's also check stderr for any exeptions"
exception=`/usr/bin/find $errpath -name "ContractsAndDiscountsProcessor_err" -type f  -mtime -1 | wc -l`

if [ $exception -eq 0 ]; then 
	echo "No errors identified on the stderr output, no actions needed"
else
	echo "Need to inform users, $errpath/ContractsAndDiscountsProcessor_err has been modified yesterday!"
	(echo -e "$errpath/ContractsAndDiscountsProcessor_err has been modified yesterday, need to check billing discounts.\n"; echo -e "\nLast logs are:\n" ; cat $errpath/ContractsAndDiscountsProcessor_err | tail -n 4) | mail -aFrom:truncateBilling@curbas.gr -s "contractsAndDiscounts Data" $email_recipients
fi
echo "That's all"


