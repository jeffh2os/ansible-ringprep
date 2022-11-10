#!/bin/bash
# Scality Script to gather data stored and output free space minus 20%
# to give total free space until hitting 80% capacity cap mandated by Scality
# Created 2018
# Updated 2021/11/16
# Changes added stored data as sanity check if free space changes during node
# reboot or os updrades to verify if the stored data changed

#Date
DATE=$(date +"%Y_%m_%d_%H.%M")
#Disk Space Total (useable)
total=`curl http://admin:scality@192.168.1.50/api/v0.1/rings/DATA/ | jq '.' |grep -e diskspace_total |grep -o '[0-9]*' | awk '{foo = $1 /1024/1024/1024/1024 *.8 /2.4;print foo ""}'`
#Disk Space Consumed (written)
used=`curl http://admin:scality@192.168.1.50/api/v0.1/rings/DATA/ | jq '.' |grep -e diskspace_used |grep -o '[0-9]*' | awk '{foo = $1 /1024/1024/1024/1024 /2.4;print foo ""}'`
#Maths
free="$(echo "$total - $used" |bc )"

#Data/META stored outside arc protection
#datastored=`curl http://sanadmin:r0ck1ts4n@10.95.48.180/api/v0.1/rings/DATA/ | jq '.'|grep -e diskspace_stored |grep -o '[0-9]*'| awk '{foo = $1 /1024/1024/1024/1024 ;print foo ""}'`
#metastored=`curl http://sanadmin:r0ck1ts4n@10.95.48.180/api/v0.1/rings/META/ | jq '.'|grep -e diskspace_stored |grep -o '[0-9]*'| awk '{foo = $1 /1024/1024/1024/1024 ;print foo ""}'`


#### Output to plain text file
echo $free > /root/scality_freespace_$DATE.txt
echo "DATA",$datastored > /root/scality_stored_$DATE.txt
#echo "META",$metastored >> /root/scality_stored_$DATE.txt
