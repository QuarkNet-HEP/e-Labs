#!/bin/csh 
#
# prep_data.sh - prepare data for use by the LIGO Analysis Tool
#
# This script runs `update-rds.php -x` for a given GPS time interval
# to verify that frame files have been properly generated for that
# interval.
#
# Usage:
#         prep_data.sh -s GPS_start_time -e GPS_end_time -t trend_type -i IFO
#
# Example:
#
# If run on a machine which is not the primary RDS server (currently
# tekoa.ligo-wa.caltech.edu) then we run update-rds.php remotely on
# the RDS server via ssh, followed by running copy-rds.php to bring the
# local copy up to date.   (Note that the bin directories on the local
# and remote machines may not be in the same (relative) place.)
# 
# Eric Myers <myers@spy-hill.net>  -  10 May 2007
# @(#) $Id: data_prep.sh,v 1.4 2008/09/04 20:18:39 myers Exp $
# ######################################################################

## Configuration:

set RDS_Server = "tekoa.ligo-wa.caltech.edu"
set RDS_Login = "myers"
set BIN_DIR = "../../../../bin"



## Defaults

set GPS_start_time=
set GPS_end_time=
set Trend_Type="T"
set IFO="H"
set FLAGS=
set FILES=

set THISHOST = `hostname -s`
set PROG = `basename $0`

## Parse command line

while ( $#argv > 0 ) 
  switch ( $1 ) 
  case --help:
  case -h:                              # HELP and quit
       cat <<EOF
Syntax:
       prep_data.sh -s GPS_start_time -e GPS_end_time [-t trend_type] [-i IFO]

 where
    -t trend_type can be either T for second-trends or R for raw data
    -i IFO defaults to "H" but someday may be "L" or maybe even "G" or "V"
    -s starting GPS time of the interval
    -e ending GPS time of the interval
EOF
  case -V:
  case --version:
      set RCSVERS = \
       `echo '$Revision: 1.4 $' | sed -e 's/Revision: //'  -e 's/$\(.*\) \$/\1/'`
      set RCSDATE = \
       `echo '$Date: 2008/09/04 20:18:39 $' | sed -e 's/Date: //'  -e 's/$\(.*\) \$/\1/'`
      echo "${PROG} version $RCSVERS of $RCSDATE"
      exit 0
  case -s:  
        shift;  set GPS_start_time = $1          
        breaksw
  case -e:
        shift;  set GPS_end_time = $1          
        breaksw 
  case -i:  
        shift;  set IFO = $1          
        breaksw
  case -t: 
        shift; set Trend_Type = $1
        breaksw
  default:
   echo "Unknown argument: $1"
   echo "Type '$PROG --help' for more information."
   exit 
   breaksw
  endsw
  shift
end


# Check parameters

if( "$GPS_start_time" == "" ) then
   echo "Error: no starting time given."
   exit 1
endif

if ( "$GPS_end_time" == "" ) then
   echo "Error: no end time given."
   exit 1
endif

@ DT = $GPS_end_time - $GPS_start_time
if ( $DT < 0 ) then
  @ DT = 0 - $DT
endif

echo "Interval is $DT seconds"

if ( $DT > 3600 ) then
  echo "WARNING: $DT is a long interval for Trend_Type $Trend_Type"
endif


##
# Issue update -x command, either for local or remote host

set CMD="php $BIN_DIR/update-rds.php -x  -t $Trend_Type -i $IFO "
set CMD="$CMD -s $GPS_start_time -e $GPS_end_time"

if ( "$THISHOST" != "$RDS_Server" ) then
  set CMD="php bin/update-rds.php -x  -t $Trend_Type -i $IFO "
  set CMD="$CMD -s $GPS_start_time -e $GPS_end_time"
  set CMD="ssh $RDS_Login@$RDS_Server $CMD"
endif
echo $CMD
$CMD


##
# Sync any local copy to RDS_Server if we are not there

if ( "$THISHOST" != "$RDS_Server" ) then
  set CMD="php $BIN_DIR/copy-rds.php -t $Trend_Type -i $IFO "
  set CMD="$CMD -s $GPS_start_time -e $GPS_end_time "
  echo $CMD
  $CMD
endif

exit
