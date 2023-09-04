#!/bin/bash

/home/gedaskalakis/curbaswtf.sh | grep -i "sa_disconnect_order_no.newvalue" | cut -f1  | awk '{printf("kill %s; \n", $1);}'



/home/gedaskalakis/curbaswtf.sh | grep -i "ps1.value_provisioned =" | cut -f1  | awk '{printf("kill %s; \n", $1);}'
/home/gedaskalakis/curbaswtf.sh | grep -i "SELECT COUNT(a.service_id) FROM service_list a, service_attributes b WHERE a.service_id = b.service_id AND a.manual_command != 30" | cut -f1  | awk '{printf("kill %s; \n", $1);}'
/home/gedaskalakis/curbaswtf.sh | grep -i "UPDATE pservice_specs SET value_new='VodafoneComms_OSM_TOM_ActivateItem" | cut -f1  | awk '{printf("kill %s; \n", $1);}'



