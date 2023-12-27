#!/bin/sh
while true
do
echo `date "+%d/%m/%y %H:%M:%S%3N"` >> Quadruplets.log 
ss -tan 'sport = :80' | awk '{print $(NF)" "$(NF-1)}' | sed 's/:[^ ]*//g' | sort | uniq -c >> Quadruplets.log
  sleep 10
done

