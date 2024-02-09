#
#	Monitor users expiration
#	   by gedaskalakis
#
#
#/bin/bash
echo "This is a script which monitors  curbas extensioned subscribers during the last 2 days."
echo -e "\nExtended users for the day before yesterday $(date +"%Y-%m-%d" --date '-2 days') are:"
grep "$(date +"%Y-%m-%d" --date '-2 days')" /opt/status/log/curbas_subs_extension.log | grep -i  -A5000  "Starting for PROD"  | grep -i "update users" | awk '{print $16}' | sort  |  uniq  | wc -l
echo -e "Yesterday $(date +"%Y-%m-%d" --date '-1 days') are:"
grep "$(date +"%Y-%m-%d" --date '-1 days')" /opt/status/log/curbas_subs_extension.log | grep -i  -A5000  "Starting for PROD"  | grep -i "update users" | awk '{print $16}' | sort  |  uniq  | wc -l
echo "Today: $(date +"%Y-%m-%d")"
grep "$(date +"%Y-%m-%d")" /opt/status/log/curbas_subs_extension.log | grep -i  -A5000  "Starting for PROD"  | grep -i "update users" | awk '{print $16}' | sort  |  uniq  | wc -l

