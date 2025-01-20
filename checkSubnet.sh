#!/bin/bash

COMMUNITY="Kfc123!!@"
# Prompt the user for the SNMP community string and subnet
read -p "Enter the subnet (e.g., 192.168.201): " SUBNET

if [[ ! $SUBNET =~ ^([0-9]{1,3}\.){2}[0-9]{1,3}([.][0-9]{1,3})?$ ]]; then
    echo "Invalid input. Please enter a valid subnet (e.g., 192.168.201) or IP (e.g., 192.168.1.1)."
    exit 1
fi

# Check if a single IP was provided
if [[ $SUBNET =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Checking $SUBNET..."
    timeout 2 snmpwalk -v 2c -c "$COMMUNITY" "$SUBNET" SysName
else
    # Loop through all IP addresses in the subnet
    for i in {1..254}; do
        IP="$SUBNET.$i"
        echo "Checking $IP..."
        timeout 2 snmpwalk -v 2c -c "$COMMUNITY" "$IP" SysName
    done
fi
