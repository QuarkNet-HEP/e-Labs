#!/bin/bash
#
# sets the standard parameters for the uwatmos DAQ cosmic ray mode.
# run this with two (non-flagged) command line values, date and runnum.
# at now
#./standardrun.sh 20031114 0

mydate=$1
mynum=$2

./qnetdaq.exe --gatewidth=10 --tmcdelay=6 --baudrate=56700 \
          --seconds=3600 --events=500000 --singles_seconds=100 \
          --coincidence=3 --loglevel=0  --firmware=32 \
          --name=labmuon_${mydate} --num=${mynum}

