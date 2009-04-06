#!/bin/sh 
#
# Run the LIGO analysis plot1chan to plot a single channel,
# using the run_dmtroot.sh script
#
# Swift Signature:
#
#  app {
#        plotNchan.sh taskid ChanListFile Nchan GPSstart GPSend tAxisPref 
#      }  
#
# Environment:
#   TLA_ROOT_DIR points to the directory containing run_dmtroot.sh etc.
#
#
#  NB. error codes for this script should start at 30
#
# Eric Myers <myers@spy-hill.net>  - 2 November 2007
# @(#) $Id: plotNchan.sh,v 1.2 2008/08/21 14:28:01 myers Exp $
#######################################################################
GPSepoch=315964800		# start of GPS time, in Unix time 

# Defaults:

ttype="M"			# trend type: M, S, R, [D, H]  
tAxisPref="GMT"			# GMT or GPS?
NOW=`date -u +%s`
GPSend=$(( $NOW-$GPSepoch ))
GPSstart=$(( $GPSend - 24*3600 ))
TaskID=`hostname`_$$

MYNAME=`basename $0 .sh`
echo "$MYNAME - simple test of reading LIGO data"


##
# Usage message

usage(){
    cat <<EOT
Usage:
      `basename $0` TaskID GPSstart GPSend ChanListFile --dataDir /path/to/data 
EOT
   exit 0		     
}


###############################
# Parse command line arguments, flags first

ARGS=""
FLAGS=""
QUIET=""

while [ $#  != 0 ]
do      case "$1" in
        --dataDir|-D)                   
             TLA_DATA_DIR="$2"
	     shift ;;
       --version|-V)  
             VER=`echo "$Revision: 1.2 $ " | awk '{print $2}' `
             DATE=`echo "$Date: 2008/08/21 14:28:01 $ " | awk ' {$1=""; $NF=""; print'} `
             echo "This is $MYNAME version $VER of $DATE" 
             exit 0                   ;;
       --help|-h)
	     usage			
	     exit 0			;;  
        -*)  FLAGS="$FLAGS $1"        ;; #  other flags (unused)
         *)  ARGS="$ARGS $1"          ;; #  files (unused)
        esac

        shift
done

##
# Positional arguments, if there are any

if [ -z "$ARGS" ]; then
  echo "No command line arguments given."
  usage
else
  set $ARGS

  if [ $# -lt 4 ]; then
    echo "Command line arguments are incomplete.  Only $# arguments given.  "
    usage
  fi

  # Task ID 

  TaskID=$1
  shift   

  # Channel name

  ChanListFile=$1 
  shift;

  # Number of channels

  Nchan=$1
  shift;

  # GPS start/end times 

  GPSstart=$1
  GPSend=$2
  shift; shift

  # Time Axis preferenc: GMT or GPS?

  if [ $# -gt 1 ]; then
    tAxisPref=$1  
    shift
  fi
fi


# Log file:

LOGFILE=${MYNAME}.log
/bin/rm -f $LOGFILE



###############################
# Sanity checks

# TaskID had better be set by now

echo "Task ID: $TaskID "
if [ -z "$TaskID" ]; then
   echo "Error: no TaskID.  Something is wrong with the script."
   exit 31
fi

# GPS time interval

echo "Interval: $GPSstart to $GPSend "
if [ -z "$GPSstart" -o -z "$GPSend" ]; then
   echo "$MYNAME requires a GPS time interval.  "
   exit 32
fi

# Channel Name

echo "Channel file: $ChanListFile "
if [ -z "$ChanListFile" ]; then
  echo "$MYNAME requires a list of channel names, in a file.  "
  exit 33
fi

# If TLA_DATA_DIR is set then pass it on through the environment.
# Otherwise, we hope that run_dmtroot.sh will be able to find it.

if [ ! -z "$TLA_DATA_DIR" ]; then
  export TLA_DATA_DIR
fi

# If TLA_ROOT_DIR is set then we'll use it. 
# Otherwise, we hope that run_dmtroot.sh will be able to find it.

if [ -z "$TLA_ROOT_DIR" ]; then
  # At least try finding it in the same directory, but don't export it,
  # as we'll let run_dmtroot.sh look more carefully
  X=`dirname $0`
  TLA_ROOT_DIR=$X/../../root
  TLA_VI_DIR=$X/../../vi
  export TLA_ROOT_DIR
  export TLA_VI_DIR
fi


###############################
# Construct ROOT command.
#
# Be careful with quoting.  Either use double quotes, or escape the parens,
#   but not both.
# Be careful with spaces.  ROOT won't tolerate spaces in an arg list.
# Full path to the script named on the command line seems to be needed.
# TLA_ROOT_DIR is determined by run_dmtroot.sh, so escaping the $ causes 
#   evaluation after it's been set.

ROOT_CMD="\$TLA_VI_DIR/plotNchan/plotNchan.C(\"$TaskID\",\"$ChanListFile\""
ROOT_CMD="$ROOT_CMD,$Nchan,$GPSstart,$GPSend,\"$ttype\",\"$tAxisPref\")"

echo "Invoking run_dmtroot.sh..."
time $TLA_ROOT_DIR/run_dmtroot.sh $TaskID $ROOT_CMD
RC=$?
echo "ROOT ran, with return code $RC "

[ -f $LOGFILE ] && cat $LOGFILE && rm -f $LOGFILE

echo "${MYNAME}: done."
exit $RC

##EOF##
