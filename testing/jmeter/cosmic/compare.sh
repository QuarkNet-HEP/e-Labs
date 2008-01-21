#!/bin/sh

sleep 2
if [ "$REFPATH" == "" ]; then
	REFPATH="."
fi
TYPE=$1
REF="reference-$TYPE.png"
URL=$2
LOG="$REFPATH/compare-$TYPE.log"
echo "" >>$LOG
echo "" >>$LOG
echo "----------------------------------------" >>$LOG
date >>$LOG
echo "----------------------------------------" >>$LOG

wget -o $LOG.2 -r -O $REFPATH/output-$TYPE.png $URL
cat $LOG.2 >>$LOG

#Make sure we have a valid file
SZ=`stat -c %s $REFPATH/output-$TYPE.png`
if [ "$SZ" == "0" ]; then
	echo "Zero sized image. Re-trying" >>$LOG
	sleep 5
	wget -o $LOG.2 -r -O $REFPATH/output-$TYPE.png $URL
	cat $LOG.2 >>$LOG
else
	echo "Non-empty image" >>$LOG
fi

rm -f $LOG.2

echo "URL: $URL" >>$LOG
echo "REFPATH: $REFPATH" >>$LOG

DIFF=`compare -metric MAE $REFPATH/reference-$TYPE.png $REFPATH/output-$TYPE.png null: 2>&1`

ND=`echo $DIFF | grep "dB"`

if [ "$?" == "0" ]; then
	echo "Old IM" >>$LOG
	DIFF=`echo $ND | awk -- '{print $1}'`
fi

echo "DIFF: $DIFF">>$LOG

if perl -e "$DIFF < 20 || die 1;"; then
	echo "good enough"
else
	echo "mean absolute error: $DIFF"
fi
