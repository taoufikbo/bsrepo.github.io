#!/bin/sh

usage() {
  echo "usage: portstats.sh PORT_1 PORT_2 ... PORT_N"
  echo "       Summarize network connection statistics coming into a set of ports."
  echo ""
  echo "       OPENING represents SYN_SENT and SYN_RECV states."
  echo "       CLOSING represents FIN_WAIT1, FIN_WAIT2, TIME_WAIT, CLOSED, CLOSE_WAIT,"
  echo "                          LAST_ACK, CLOSING, and UNKNOWN states."
  echo ""
  exit;
}

NUM_PORTS=0
OS=`uname`

for c in $*
do
  case $c in
  -help)
    usage;
    ;;
  --help)
    usage;
    ;;
  -usage)
    usage;
    ;;
  --usage)
    usage;
    ;;
  -h)
    usage;
    ;;
  -?)
    usage;
    ;;
  *)
    PORTS[$NUM_PORTS]=$c
    NUM_PORTS=$((NUM_PORTS + 1));
    ;;
  esac
done

if [ "$NUM_PORTS" -gt "0" ]; then
  date
  NETSTAT=`netstat -an | grep tcp`
  i=0
  for PORT in ${PORTS[@]}
  do
    if [ "$OS" = "AIX" ]; then
      PORT="\.$PORT\$"
    else
      PORT=":$PORT\$"
    fi
    ESTABLISHED[$i]=`echo "$NETSTAT" | grep ESTABLISHED | awk '{print $4}' | grep "$PORT" | wc -l`
    OPENING[$i]=`echo "$NETSTAT" | grep SYN_ | awk '{print $4}' | grep "$PORT" | wc -l`
    WAITFORCLOSE[$i]=`echo "$NETSTAT" | grep WAIT | awk '{print $4}' | grep "$PORT" | wc -l`
    WAITFORCLOSE[$i]=$((${WAITFORCLOSE[$i]} + `echo "$NETSTAT" | grep CLOSED | awk '{print $4}' | grep "$PORT" | wc -l`));
    WAITFORCLOSE[$i]=$((${WAITFORCLOSE[$i]} + `echo "$NETSTAT" | grep CLOSING | awk '{print $4}' | grep "$PORT" | wc -l`));
    WAITFORCLOSE[$i]=$((${WAITFORCLOSE[$i]} + `echo "$NETSTAT" | grep LAST_ACK | awk '{print $4}' | grep "$PORT" | wc -l`));
    WAITFORCLOSE[$i]=$((${WAITFORCLOSE[$i]} + `echo "$NETSTAT" | grep UNKNOWN | awk '{print $4}' | grep "$PORT" | wc -l`));

    TOTESTABLISHED=0
    TOTOPENING=0
    TOTCLOSING=0
    i=$((i + 1));
  done

  printf '%-6s %-12s %-8s %-8s\n' PORT ESTABLISHED OPENING CLOSING
  i=0
  for PORT in ${PORTS[@]}
  do
    printf '%-6s %-12s %-8s %-8s\n' $PORT ${ESTABLISHED[$i]} ${OPENING[$i]} ${WAITFORCLOSE[$i]}
    TOTESTABLISHED=$(($TOTESTABLISHED + ${ESTABLISHED[$i]}));
    TOTOPENING=$(($TOTOPENING + ${OPENING[$i]}));
    TOTCLOSING=$(($TOTCLOSING + ${WAITFORCLOSE[$i]}));
    i=$((i + 1));
  done

  printf '%36s\n' | tr " " "="
  printf '%-6s %-12s %-8s %-8s\n' Total $TOTESTABLISHED $TOTOPENING $TOTCLOSING

else
  usage;
fi
