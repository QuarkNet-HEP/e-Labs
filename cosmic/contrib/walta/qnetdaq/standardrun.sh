#!/bin/bash
#
# sets the standard parameters for the uwatmos DAQ cosmic ray mode.
# run this with two (non-flagged) command line values, date and runnum.
# at now
#./standardrun.sh 20031114 0

mydate=$1
mynum=$2

./qnetdaq.exe --gatewidth=150 --tmcdelay=50 --baudrate=38400 \
          --seconds=10000 --events=10000 --firmware=32 \
          --coincidence=2 --loglevel=0   \
          --name=uwatmos_${mydate} --num=${mynum}

