#!/bin/sh
#Delete files and folders more than x minutes
#To run this script you can make an entry the cameras crontab
#You might need to create manually the folder structure /var/spool/cron/crontabs 
#or when you try to add a crontab with "crontab -e" it might give you an error
#search on internet about the use of crontab
minutes=+1440 # 24*60

#empty record
dir="/home/hd1/record/"
dt=`date +%y%m%d`

du -sh ${dir} > ${dir}Delete_$dt.log
find ${dir} -mmin $minutes -exec rm -Rf {} \;
du -sh ${dir} >> ${dir}Delete_$dt.log

#empty record_sub
dir="/home/hd1/record_sub/"
dt=`date +%y%m%d`

du -sh ${dir} > ${dir}Delete_$dt.log
find ${dir} -mmin $minutes -exec rm -Rf {} \;
du -sh ${dir} >> ${dir}Delete_$dt.log

