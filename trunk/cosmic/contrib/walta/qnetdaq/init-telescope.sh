#!/bin/bash
#
# sets the standard parameters for the uwatmos DAQ cosmic ray mode.
# this sets the card, but then exits without taking data.

./qnetdaq.exe --gatewidth=10 --tmcdelay=6 --baudrate=38400 \
          --seconds=1 --events=0 --files=1 \
          --coincidence=2 --loglevel=0  --setuponly \
          --name=init --num=0

rm data/init_000.txt

