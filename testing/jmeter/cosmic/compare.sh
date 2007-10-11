#!/bin/sh

sleep 2
TYPE=$1
REF="reference-$TYPE.png"
URL=$2
LOG=compare-$TYPE.log
wget -o $LOG -r -O output-$TYPE.png $URL 
echo "URL: $URL" >>$LOG

DIFF=`compare -metric MAE reference-$TYPE.png output-$TYPE.png null: 2>&1`

echo "DIFF: $DIFF">>$LOG

if [ "$DIFF" -lt "20" ]; then
	echo "good enough"
else
	echo "mean absolute error: $DIFF"
fi
