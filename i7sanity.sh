#!/bin/bash
#						#
#						#
#   Simple Scirpt for monitoring and actual     #
#	  sanity  for the nonRFSK5 cases	#
#		by gedaskalakis                	#
#						#
#						#
#						#


script_path="/opt/curbas/scripts/tools/rfs"


function stage1()
{
echo -e "let's restart the flow\nWe are @ the start HURRAY!!"
return 
}

while true; do
	echo -e "Hi There, you wanna extract the cases or send an RFS with a specified service ID? \nPress \"rfs\" to send rfs or \"extract\" to extract the file"
	read -p "Input data:" rfsextract
	case $rfsextract in
		#lets send RFS
		rfs) echo -e "Let's send a standalone rfs using PORTABILITY's serviceID" ; date ; echo "RFS stage"; 
			echo -n "Provide the service_id which you wanna send RFS:"
			read service_id
			USAGE="Provide a valid integer service_id!!"
			while true; do
				if [ "$service_id" -eq "$service_id" ] 2>/dev/null ; then
		    			echo "$service_id is a valid service_id!"
					break
				else
		    			echo "ERROR: service_id must be an integer!"
			    		echo -e "\033[31m$USAGE\033[0m";
			    		exit 1
				fi
			done
			#actual rfs phase
			echo ------------------------------------------------------------------------  >>$script_path/i7sanity_rfs.log 2>&1
			echo -e "\nDate is `date +"%d:%m:%Y %H:%M:%S"` and the logs for the rfs are :" >>$script_path/i7sanity_rfs.log 2>&1
			ssh 10.120.161.100 -l "HOLNET\gedaskalakis" "/opt/provisioning/scripts/provisioning/service_elements/portability/activationMonitor/activationMonitor_fromService.sh $service_id;" >>$script_path/i7sanity_rfs.log 2>&1
			valid=$?
			echo -e "\n"
			tail -n 8 /opt/curbas/scripts/tools/rfs/i7sanity_rfs.log | grep   -A10  "the logs for the rfs are"	
			echo -e "\n"			
			if [ ${valid} -eq 0 ]; then
				echo "All went well, let's check if the rfs has been sent or failure arise"
				success=`tail -n 8 /opt/curbas/scripts/tools/rfs/i7sanity_rfs.log | grep   -A10  "the logs for the rfs are" | grep -i "RFS sent successfuly" | wc -l`
				if [ ${success} -eq 1 ] ; then
					echo -e "Rfs for $service_id has been succesfully sent!\nYou can find the RFS actual logs here :$script_path/i7sanity_rfs.log"
				else
					echo -e "Rfs has not been sent due to various reasons, check the above output log OR check /opt/curbas/scripts/tools/rfs/i7sanity_rfs.log"
				fi
			else

				echo "Something on the process went wrong, check the rfs logs. "
			fi
			break;;


		#Lets extract the affected cases
		extract) echo "Let's extract all the affected cases, check the logfile : $script_path/i7sanity.log  afterwards"
		echo -e "Group_id \t UID \t  MANUAL_RFS \t PRODUCT \t withLLU \t NULL \t LLU \t\t LLU \t\t KStatus" >$script_path/i7sanity.log 
		/usr/local/bin/dbexec curbasslave -sNe "select a.group_id, a.contract_id, m.value_new, b.value_new, c.value_new, c.value_provisioned, g.value_new, g.value_provisioned ,f.comment  from pservices a, pservices d, pservice_specs b, pservice_specs c, pservices f, pservice_specs g, pservices k, pservice_specs m where a.contract_id=k.contract_id and k.id=m.owner_id and m.spec_id=1399 and a.prototype_id=111 and a.comment like 'I7%' and a.id=b.owner_id and a.contract_id=d.contract_id and d.id=c.owner_id and b.spec_id=1405 and c.spec_id=1411 and b.value_new IN ('Double Play POTS','Office Double Play','Double Play CBT','POTS Telephony','Double Play VoIP','Triple Play CBT','Triple Play POTS','Triple Play VoIP') and f.contract_id=a.contract_id and f.prototype_id=84 and f.comment like 'Ê3%' and f.id=g.owner_id and g.spec_id=668" >> $script_path/i7sanity.log ; date ; echo "The affected cases are:" ; 
		cat $script_path/i7sanity.log 
		count=`cat $script_path/i7sanity.log | cut -f2 | grep -iv uid | uniq | wc -l`
		cat $script_path/i7sanity.log | cut -f2 | uniq > $script_path/i7sanity_uid.log

		echo -e "\033[33mThere are $count unique UIDS, you can find them in \"$script_path/i7sanity_uid.log\" \033[0m"; break;;


		#/usr/local/bin/dbexec curbasslave -sNe "select max(ID) from pservices" >> $script_path/i7sanity.log ; date ; echo "The affected cases are:" ; cat $script_path/i7sanity.log ;  break;;
		

		*) echo -e '\033[31mWrong answer, please respond with "rfs" OR "extract"\033[0m';;
	esac
done


while true; do
 	read -t 30 -p 'Do you need anything else? "yes/no":' yesno
	case $yesno in
	[yesYES]*) echo "Let's restart";  stage1;;
	[noNO]*) echo "Ok, then bye bye"; exit;;
	*) echo "No answer, retry" ;;
	esac
done


rerun()
{
while true; do
        echo -e "Hi There, you wanna extract the cases or send an RFS with a specified service ID? \nPress \"rfs\" to send rfs or \"extract\" to extract the file"
        read -p "Input data:" rfsextract
        case $rfsextract in
                rfs) echo -e "Let's send a standalone rfs using PORTABILITY's serviceID" ; date ; echo "rfs"; break;;

                #Lets extract the affected cases
                extract) echo "Let's extract all the affected cases, check the logfile :i7sanity.log afterwards"
                echo -e "Group_id \t UID \t  MANUAL_RFS \t PRODUCT \t NOTwithLLU \t withLLU \t LLU \t LLU \t KStatus" >$script_path/i7sanity.log
                #/usr/local/bin/dbexec curbasslave -sNe "select a.group_id, a.contract_id, m.value_new, b.value_new, c.value_new, c.value_provisioned, g.value_new, g.value_provisioned ,f.comment  f
                /usr/local/bin/dbexec curbasslave -sNe "select max(ID) from pservices" >> $script_path/i7sanity.log ; date ; echo "The affected cases are:" ; cat $script_path/i7sanity.log ;  break;


                *) echo -e '\033[31mNo answer, please respond with "rfs" OR "extract"\033[0m';;
        esac
done
}

