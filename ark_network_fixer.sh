#!/bin/bash

INTERACTIVE=
BKP=

while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    -i|--interactive)
      INTERACTIVE=1
      ;;
    -b|--backup)
      BKP=1
      ;;
  esac
  shift
done

SUBNETWORK=`ifconfig | grep 192.168. | awk '{print $2}' | cut -d: -f2 | cut -d. -f3`
case $SUBNETWORK in
 1)
   OLD_SUBNET=2;
   ;;
 2)
   OLD_SUBNET=1;
   ;;
 *)
   echo "Subnetwork $SUBNETWORK is not identified.
Quit without fixing the network configuration";
   exit 1;
   ;;
esac

grep "192.168.""$OLD_SUBNET""." /etc/hosts > /dev/null 2>&1
if [[ $? -ne 0 ]];then
  echo "No entries found with the old subnet $OLD_SUBNET
Nothing to do. Bye..."
  exit 0;
fi

HOSTS_FILE="/etc/hosts"
HOSTS_BKP="$HOSTS_FILE"_`date +'%F_%s' -u`.bkp

if [[ ! -z $INTERACTIVE ]]; then
  sed 's/^192.168.'"$OLD_SUBNET"'./192.168.'"$SUBNETWORK"'./' $HOSTS_FILE

  CONT='n'

  read  -p "> Do you want to change $HOSTS_FILE?[y:N]" CONT

  case $CONT in
    Y*|y*)
    ;;
    *)
      exit
    ;;
  esac

  if [[ -z $BKP ]]
  then
    CONT='n'

    read  -p "> Do you want to take backup?[y:N]" CONT

    case $CONT in
      Y*|y*)
        echo "Taking backup for $HOSTS_FILE at $HOSTS_BKP..."
        cp $HOSTS_FILE $HOSTS_BKP
      ;;
      *)
      ;;
    esac
  else
    echo "Taking backup for $HOSTS_FILE at $HOSTS_BKP..."
    cp $HOSTS_FILE $HOSTS_BKP
  fi
fi

sed -i 's/^192.168.'"$OLD_SUBNET"'./192.168.'"$SUBNETWORK"'./' $HOSTS_FILE

echo "$HOSTS_FILE updated.
Bye..."