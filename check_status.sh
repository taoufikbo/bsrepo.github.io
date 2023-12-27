#!/bin/sh

while true
do

code=$(curl -sL -w "%{http_code} %{time_total}" "http://10.106.140.117/status" -o /dev/null)
echo `date "+%d/%m/%y %H:%M:%S%3N"` $code >> CheckstatutWeb.log
  sleep 5
done

