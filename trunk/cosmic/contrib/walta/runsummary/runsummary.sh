#!/bin/bash

for school in devry issaquah juanita liberty meadowdale muhshome nathanhale redmond uwatmos
do

list=`ls /data/walta/sitedata/${school}/${school}_*.txt | tail -5`

./runsummary.exe ${list} > ${school}_runsummary.txt

done
