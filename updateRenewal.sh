#!/bin/bash

#A script to apply a manual temporarily patch for BM Renewal
script_path="/opt/curbas/scripts/tools/MonitorScripts"



/opt/status/bin/dbrun  curbas  "update contractsAndDiscounts set discount_name = 'GREATVALUE_RENEWAL_XXXX_24' where use_case = 'Renewal' and status = 'initial' and billing_processed = 'N' and comment = 'Waiting for activation' and isnull(discount_name) and entity = 'Discount'"  1>$script_path/updateRenewal.log 2>&1

echo "Let's send a mail to verify everything is ok"
(echo -e "Today's Renewals: \n" ;cat $script_path/updateRenewal.log ; uuencode "/opt/curbas/scripts/tools/MonitorScripts/updateRenewal.log" "updateRenewal.log") | mail -aFrom:truncateBilling@curbas.gr -s "renewal_patch" georgios.daskalakis1@vodafone.com Georgios.Lamprinakos@vodafone.com georgios.galanos@vodafone.com Georgios.Christakos@vodafone.com

echo "That's all, mail sent, updated today's records"
