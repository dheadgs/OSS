#!/bin/bash
# Created by Intracom-Telecom, 
# It is recommened to run his script under "/tmp" folder
#
# Define variables
#
URL=10.120.170.81:59200
INDEX_TO_TO_EXPORT=ngi_buildings
SIZE=10000

function jsonValue() {
KEY=$1
num=$2
awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}

echo -e "Starting..."
JSON_RESPONSE=$(curl -s XGET "${URL}/${INDEX_TO_TO_EXPORT}/_count")
DOCS=$(echo $JSON_RESPONSE |jsonValue count)
echo -e "Documents of index are $DOCS"

curl -s XGET "${URL}/${INDEX_TO_TO_EXPORT}/_search?filter_path=_scroll_id&scroll=10m&size=${SIZE}" > outfile_scroll.json
#curl -s XGET "${URL}/${INDEX_TO_TO_EXPORT}/_search?filter_path=hits.hits._source&_source_includes=eltaStreet,bendleyStreet,number,evenNumberRange,postalCode,area,building,buildingDocumentId,buldingDocumentId&size=10000&scroll=10m&pretty=1" > outfile_part1.json
curl -s XGET "${URL}/${INDEX_TO_TO_EXPORT}/_search?filter_path=hits.hits._source&size=${SIZE}&scroll=10m&pretty=1" > outfile_part1.json
SCROLL_ID=$(cat outfile_scroll.json |jsonValue _scroll_id)
echo -e "Scroll_id  is $SCROLL_ID"

counter=2;
ITERATIONS=$((DOCS / SIZE))
while [ "$ITERATIONS" != "0" ]; do
	echo -e "new round. Counter is ${counter}. SCROLL_ID is $SCROLL_ID"
	curl -s XGET "${URL}/_search/scroll?filter_path=hits.hits._source&pretty=1$" -d "{ \"scroll\": \"10m\", \"scroll_id\": \"${SCROLL_ID}\" }" > outfile_part${counter}.json
	counter=$((counter+1))
	ITERATIONS=$((ITERATIONS - 1))
done

#
#
#Use the below link if you want to convert json in csv
#https://sqlify.io/convert/json/to/csv
#Save csv files with UTF-8 BOM encoding.
#
