#!/bin/bash
# make an ordered list of files.  
# don't forget to edit them to remove the crap.

for datadir in bernshome issaquah liberty meadowdale muhshome nathanhale redmond roosevelt juanita devry uwatmos
do

ls -1 /data/walta/sitedata/${datadir}/${datadir}_*.txt > file_${datadir}.txt

done
