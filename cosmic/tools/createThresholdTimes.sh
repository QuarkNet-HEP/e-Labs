#!/bin/bash

LOG=$PWD/installThresholdTools.log
DIR=~/ThresholdTimes

usage() {
	cat <<END
This is a tool used to install:
    1. ThresholdTimesProcess

Usage:
    installThresholdTools.sh 
where:
END
	exit 1
}

stepne() {
	step "$@"
	IGNOREERROR="yes"
}

step() {
	if [ "$FIRSTSTEP" = "no" ]; then
		if [ "$?" != "0" -a "$IGNOREERROR" != "yes" ]; then
			echo "Failed"
			exit 3
		else
			echo "Done"
			echo >>$LOG
		fi
	else
		FIRSTSTEP="no"
	fi
	IGNOREERROR="no"
	if [ "$1" != "" ]; then
		echo -n "$1..."
		echo "$1..." >>$LOG
	fi
}

fail() {
	echo $1
	echo "See log ($LOG) for details"
	exit 4
}

echo >>$LOG
echo >>$LOG
echo "------------------------------" >>$LOG
date >>$LOG
echo "------------------------------" >>$LOG
echo >>$LOG

step "Creating I2U2 tools directory"
mkdir -p $DIR/cosmic/src/java/ >>$LOG 2>&1
mkdir -p $DIR/bin >>$LOG 2>&1


step "Fetching I2U2 java code from SVN"
#svn co --non-interactive --trust-server-cert \
svn co \
https://svn.ci.uchicago.edu/svn/i2u2/branches/test/cosmic/src/java/ \
$DIR/cosmic/src/java >>$LOG 2>&1

step "Compiling I2U2 java code"
javac $DIR/cosmic/src/java/gov/fnal/elab/cosmic/analysis/ThresholdTimesProcess.java -d $DIR/bin/ >>$LOG 2>&1

step " "

#1-sudo as quarkcat
#2-run this script in your user folder where the cosmic data is
#3-this script creates a ThresholdTimes folder and two folders inside /bin and /java
#4-once the script ran successfully, inside bin run the following command:
#java gov.fnal.elab.cosmic.analysis.ThresholdTimesProcess /path/to/input/file/input_file_created_from_the_database.txt
#NOTE: input file needs the following columns separated by commas:
#    //1-data path (eg. /disks/i2u2-dev/cosmic/data
#    //2-input file name (eg. 6119.2013.0522.1)
#    //3-output file name (eg. 6119.2013.0522.1.thresh)
#    //4-cpld frequency for that file (eg. 25000000)