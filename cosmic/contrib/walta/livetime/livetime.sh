#!/bin/bash


#date="--startdate=20040400"
date="--startdate=20050100 --enddate=20050132"
#date="--startdate=20041000 --enddate=20041032"
#date="--startdate=20040900 --enddate=20040932"
#date="--startdate=20040800 --enddate=20040832"
#date="--startdate=20040700 --enddate=20040732"
#date="--startdate=20040600 --enddate=20040632"
#date="--startdate=20040500 --enddate=20040532"
#date="--startdate=20040400 --enddate=20040432"

dir=/data/walta/sitedata
echo $date

for datadir in bernshome issaquah liberty meadowdale muhshome nathanhale redmond roosevelt juanita devry uwatmos
#for datadir in uwatmos
do

  echo ${datadir} `./livetime.exe ${date} --silent --testtime=50 ${dir}/${datadir}/${datadir}_*.txt  | grep livetime`

done


date="--startdate=20040400"

dir=/data/walta/sitedata
echo $date
for datadir in bernshome issaquah liberty meadowdale muhshome nathanhale redmond roosevelt juanita devry uwatmos
#for datadir in uwatmos
do

  echo ${datadir} `./livetime.exe ${date} --silent --testtime=50 ${dir}/${datadir}/${datadir}_*.txt  | grep livetime`


done


