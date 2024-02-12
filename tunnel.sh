#!/bin/bash
#							#
#    Script to create/kill ansible tunnels		#
#		by gdaskalakis				#
#							#
#							#
#							#
#########################################################


scriptpath="/opt/scripts/"
action=$1
active_tunnels=`pgrep -lf tunnel | grep -i ssh | wc -l`
echo -e "Date is: `date +"%d:%m:%Y %H:%M:%S"`\n"
echo "There are $active_tunnels active tunnels right now"
echo
ps afux | grep -iv grep | grep -i "zenith_*"
echo

print_help(){
cat << EOF
Shell script that creates or kill ssh tunnel to the zabbix proxies

  Usage: tunnel.sh [create/kill]

EOF
exit 0
}

function kill_tunnel()
{
while true; do
	read -t 10 -p "Which tunnel you want to kill? Answer as (A)zure/a(W)s/(V)mware or (E)xit: " awve
   case $awve in
        [Aa]* ) pkill -f zenith_azure_tunnel; break;;
	[Ww]* ) pkill -f zenith_aws_tunnel; break;;
	[Vv]* ) pkill -f zenith_vmware_tunnel; break;;
        [Ee]* ) exit;;
        * )     echo "No answer defined, exiting..."; break;;
    esac
done
}


function create_tunnel()
{
while true; do
        read -t 10 -p "Which tunnel you want to create? Answer as (A)zure/a(W)s/(V)mware or (E)xit:  " awve
   case $awve in
	[Aa]* ) nohup $(exec -a zenith_azure_tunnel ssh -D 0.0.0.0:2001 -N -f -C root@zenith3) 1>/dev/null 2>&1 & break;;
	[Ww]* ) nohup $(exec -a zenith_aws_tunnel ssh -D 0.0.0.0:2002 -N -f -C root@zenith4) 1>/dev/null 2>&1 & break;;
	[Vv]* ) nohup $(exec -a zenith_vmware_tunnel ssh -D 0.0.0.0:2000 -N -f -C root@zenith1) 1>/dev/null 2>&1 & break;;
        [Ee]* ) exit;;
        * )     echo "No answer defined, exiting..."; break;;
    esac
done
}

if [ "$#" -ne 1 ]; then
    echo
    print_help
    
    exit 1
fi

case "$1" in
    create) create_tunnel;;
    kill) kill_tunnel;;
    *) print_help;;
esac

