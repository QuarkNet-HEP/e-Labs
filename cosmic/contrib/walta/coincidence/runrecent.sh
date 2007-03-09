#!/bin/bash

./coincidence.exe --filelist --coincidence=2 --testtime=1.0E-5 --silent --startdate=20040800 file_*.txt > recent.txt

./coincidence.exe --filelist --coincidence=2 --testtime=1.0E-4 --silent --startdate=20040800 file_*.txt > fullrecent.txt
