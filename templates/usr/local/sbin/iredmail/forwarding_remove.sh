#!/bin/bash
# {{ ansible_managed }}
# ansibleguy.sw_iredmail

# see: https://docs.iredmail.org/sql.user.mail.forwarding.html | https://docs.iredmail.org/sql.create.catch-all.html

set -e

MYSQL_CLI='mysql -uroot --socket {{ IRM_CONFIG.database.socket }}'

if [ -z "$1" ]
then
  echo ''
  echo 'You need to supply the source email or domain to remove as argument!'
  echo 'Example: forwarding_remove.sh test@template.ansibleguy.net'
  echo ''
  exit 1
fi

SOURCE="$1"

echo ''

if $MYSQL_CLI -e "SELECT address FROM vmail.forwardings where address='$SOURCE';" | grep -q "$SOURCE"
then
  $MYSQL_CLI -e "DELETE FROM vmail.forwardings WHERE address='$SOURCE';"
  echo "Removed forwarding for source '$SOURCE'!"
else
  echo "Forwarding for source '$SOURCE' do not exist!"
fi

echo ''
