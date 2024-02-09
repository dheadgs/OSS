#!/bin/bash
/opt/status/bin/dbrun curbas "select a.group_id, a.prototype_id, b.id from received_notifications a left outer join pservices b on a.group_id = b.group_id and a.prototype_id = b.prototype_id where b.id is null;" dbprintf "%s %s\n" 2>/dev/null | awk '{printf("delete from received_notifications where group_id = %s and prototype_id = %s limit 2; \n", $1, $2);}' | dbgo | grep -iv "connect" | awk NF 

echo "All pending Notifications are deleted"



