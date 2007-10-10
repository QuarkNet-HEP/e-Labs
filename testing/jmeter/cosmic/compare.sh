#!/bin/sh

TYPE=$1
REF="reference-$TYPE.png"
URL=$2

wget -r -O output-$TYPE.png $URL

DIFF=`compare -metric MAE reference-$TYPE.png output-$TYPE.png null: 2>&1`

if [ "$DIFF" -lt "20" ]; then
	echo "good enough"
else
	echo "mean absolute error: $DIFF"
fi
