#!/bin/sh

sleep 2
if [ "$REFPATH" == "" ]; then
	REFPATH="."
fi
TYPE=$1
REF="reference-$TYPE.png"
URL=$2
LOG="$REFPATH/compare-$TYPE.log"
wget -o $LOG -r -O $REFPATH/output-$TYPE.png $URL 
echo "URL: $URL" >>$LOG
echo "REFPATH: $REFPATH" >>$LOG

DIFF=`compare -metric MAE $REFPATH/reference-$TYPE.png $REFPATH/output-$TYPE.png null: 2>&1`

echo "DIFF: $DIFF">>$LOG

if [ "$DIFF" -lt "20" ]; then
	echo "good enough"
else
	echo "mean absolute error: $DIFF"
fi
