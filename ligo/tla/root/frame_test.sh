#!/bin/sh 
#
# Run the frame_test.C() ROOT script from the command line,
# or via Swift, using the run_dmtroot.sh script
#
# Swift Signature:
#
# app {
#      frame_test.sh [ TaskID [ GPSstart GPSend ]] [ --dataDir /path/to/data ]
#     }  
#
# Environment:
#   TLA_ROOT_DIR points to the directory containing run_dmtroot.sh etc.
#                If unset, try to use same directory as this script.
#
#
#  NB. Fatal error codes for this script should start at 30
#
# Eric Myers <myers@spy-hill.net>  - 18 July 2007
# @(#) $Id: frame_test.sh,v 1.5 2007/11/05 21:14:06 myers Exp $
#######################################################################
GPSepoch=315964800		# start of GPS time, in Unix time 

# Defaults:

ttype="M"			# trend type: M, S, R, [D, H]  
NOW=`date -u +%s`
GPSend=$(( $NOW-$GPSepoch ))
GPSstart=$(( $GPSend - 24*3600 ))
TaskID=`hostname`_$$

MYNAME=`basename $0 .sh`
echo "$MYNAME - simple test of reading LIGO data"

##
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
             VER=`echo "$Revision: 1.5 $ " | awk '{print $2}' `
             DATE=`echo "$Date: 2007/11/05 21:14:06 $ " | awk ' {$1=""; $NF=""; print'} `
             echo "This is $MYNAME version $VER of $DATE" 
             exit 0                   ;;
       --help|-h)
	     cat <<EOT
Usage:
      $0 [ TaskID [GPSstart GPSend] ] [ --dataDir /path/to/data ]
EOT
	     exit 0		      ;;

        -*)  FLAGS="$FLAGS $1"        ;; #  other flags (unused)
         *)  ARGS="$ARGS $1"        ;; #  files (unused)
        esac

        shift
done


##
# Positional arguments, if there are any

if [ ! -z "$ARGS" ]; then

  set $ARGS

  # Task ID (optional, here required, at least for now)

  if [ $# -gt 0 ]; then
    TaskID=$1
    shift   
  fi

  # GPS start/end times (optional)

  if [ $# -gt 1 ]; then
    GPSstart=$1
    GPSend=$2
    shift; shift
  fi

fi

echo "Task ID: $TaskID"
echo "Interval: $GPSstart to $GPSend "

##
# Sanity checks

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
  TLA_ROOT_DIR=`dirname $0`
fi

# TaskID had better be set by now

if [ -z "$TaskID" ]; then
   echo "Error: no TaskID.  Something is wrong with the script."
   exit 31
fi

# Log file:

LOGFILE=${MYNAME}.log
/bin/rm -f $LOGFILE

#
# Be careful with quoting.  Either use double quotes, or escape the parens,
#   but not both.
# Be careful with spaces.  ROOT won't tolerate spaces in an arg list.
# Full path to the script named on the command line seems to be needed.
# TLA_ROOT_DIR is determined by run_dmtroot.sh, so escaping the $ causes 
#   evaluation after it's been set.

ROOT_CMD="\$TLA_ROOT_DIR/frame_test.C($GPSstart,$GPSend,\"$ttype\") "

echo "Invoking run_dmtroot.sh..."
time $TLA_ROOT_DIR/run_dmtroot.sh $TaskID $ROOT_CMD
RC=$?
echo "ROOT ran, with return code $RC "

[ -f $LOGFILE ] && cat $LOGFILE && rm -f $LOGFILE

echo "${MYNAME}: done."
exit $RC
