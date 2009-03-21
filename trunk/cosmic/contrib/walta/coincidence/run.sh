#!/bin/bash

# before using this, execute the makelists.sh

./coincidence.exe --filelist --coincidence=2 --testtime=1.0E-5 --silent \
    file_*.txt > out-1e5.txt

#./coincidence.exe --filelist --coincidence=2 --testtime=1.0E-4 --silent \
#    file_*.txt > out-1e4.txt

./coincidence.exe --filelist --coincidence=2 --testtime=1.0E-5 --silent \
    --startdate=20040800 file_*.txt > out-recent-1e5.txt

#./coincidence.exe --filelist --coincidence=2 --testtime=1.0E-4 --silent \
#    --startdate=20040800 file_*.txt > out-recent-1e4.txt

#test these for triples, and to double check the background.

./coincidence.exe --filelist --coincidence=2 --testtime=1.0E-3 --silent \
    file_*.txt > out-1e3.txt

./coincidence.exe --filelist --coincidence=2 --testtime=1.0E-3 --silent \
    --startdate=20040800 file_*.txt > out-recent-1e3.txt

