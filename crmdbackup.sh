#!/bin/sh

WD=`pwd`
HELP=0

while [[ $# > 0 ]]
do
key="$1"

case $key in
  -w|--workingdir)
	HELP=0
	WD="$2"
	shift
  ;;
  -h|--help)
	HELP=1
	shift
  ;;

esac
shift
done


if [ $HELP -gt 0 ]
then
  echo "$HELP"
  echo "$0 [-h|--help] [-w|--workingdir WorkingDir]

Usage: Find civicrm connection parameters from WorkingDir
  - WorkingDir is the absolute path to Drupal site without trainiling slash /
  - Default WorkingDir is current working directory"
  exit 0
fi

echo "> Backup Civicrm at $WD" '
'
CRM_SETTINGS="$WD"/sites/default/civicrm.settings.php
if [ ! -f $CRM_SETTINGS ]
then
  echo 'ERROR: civicrm settings not found!
< Exit'
exit 1;
fi

DNS=`grep -E '^define.*CIVICRM_DSN.*mysql' $CRM_SETTINGS | cut -d \' -f 4`

DB_USER=`expr $DNS : '.*//\(\w*\)'`
DB_PASS=`expr $DNS : '.*//\w*:\(.*\)@'`
DB_NAME=`expr $DNS : '.*//.*@.*/\(.*\)?'`

mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" | gzip - > "$WD"/sites/default/files/backup_migrate/manual/RAVSAK_CIVICRM_`date +'%F_%s' -u`.mysql.gz

echo "> Backup Finish at $WD/sites/default/files/backup_migrate/manual Directory."
