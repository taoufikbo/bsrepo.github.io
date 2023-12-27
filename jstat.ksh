#!/bin/bash

PID=`pgrep java`

jstat -gc $PID | head -n 1 | tr -s " " "\t" >> $0.log

while true
do
   DATE=`date "+%d/%m/%y %H:%M:%S"`
   RESULT=`jstat -gc $PID | tail -n 1 | tr "." "," | tr -s " " "\t"` >> $0.log
   echo "$DATE	$RESULT" >> $0.log

   sleep 10
done
