#!/bin/bash

phonedir=/home/gedaskalakis/check.txt
phonenOcount=`cat /home/gedaskalakis/check.txt | wc -l`
start="1"

echo "Found $phonenOcount BID's to check, continuing..."
sleep 3

for (( c=$start; c<=$phonenOcount; c++))
do
currentNo=`sed -n "$c"p $phonedir`
	echo "$currentNo testing"
	echo "/usr/bin/curl -XPOST '10.120.170.81:59200/ngi_buildings/_search?pretty' -H 'Content-Type: application/json' -d' { \"queryi\": { \"match\": { \"building.id\" : \"$currentNo\"} } } ' "
	/usr/bin/curl -XPOST '10.120.170.81:59200/ngi_buildings/_search?pretty' -H 'Content-Type: application/json' -d' { "query": { "match": { "building.id" : "'$currentNo'"} } } '	
	/usr/bin/curl -XPOST '10.120.170.80:59200/ngi_buildings/_delete_by_query?pretty' -H 'Content-Type: application/json' -d'{  "query": {"bool": {"must": [{ "match": { "building.id": "'$currentNo'" }}]}}}'

done
echo "The end"

