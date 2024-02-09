#!/bin/sh

# #################################################################################################
# ##pkatsoulakis - Sep/Oct 2011									 ##
# ##Script that prints out current and max length of tables for all databases on given host	 ##
# #################################################################################################

HOST="$1"

dblist="/tmp/.dblist.$$"
mysql -h${HOST} -uweb -phellas -sNe "show databases"|grep -v mysql|grep -v test |grep -v ARCHIVE |grep -v "\_ren" > "${dblist}"

# ##Headers
echo "Database HOST; Database Name; Table Name; Table current Size; Table Max Size"

while read dbname; do
	
	tbList="/tmp/.tbList.$$"
	mysql -h${HOST} -uweb -phellas "$dbname" -sNe "show tables" > "${tbList}"
	while read tblName; do
		curData=`mysql -h${HOST} -uweb -phellas "$dbname" -sNe "show table status like '$tblName'\G"|grep "Data_length:"| sed -e 's/Data_length://g' -e 's/ //g'`
		maxData=`mysql -h${HOST} -uweb -phellas "$dbname" -sNe "show table status like '$tblName'\G"|grep "Max_data_length:"|sed -e 's/Max_data_length://g' -e 's/ //g'`
		echo "${HOST}; ${dbname}; ${tblName}; ${curData}; ${maxData}"
		
	done < "${tbList}"
	rm -rf "${tbList}"

done < "${dblist}"

rm -rf "${dblist}"
