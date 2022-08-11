#!/bin/bash
# {{ ansible_managed }}
# ansibleguy.sw_iredmail

# see: https://docs.iredmail.org/sql.create.mail.alias.html

set -e

MYSQL_CLI='mysql -uroot --socket {{ IRM_CONFIG.database.socket }}'

if [ -z "$1" ]
then
  echo ''
  echo 'You need to supply the alias email to remove as argument!'
  echo 'Example: alias_remove.sh test@template.ansibleguy.net'
  echo ''
  exit 1
fi

if ! echo "$1" | grep -q '@'
then
  echo 'The provided alias is no valid email address!'
  echo ''
  exit 1
fi

echo ''

ALIAS="$1"
if $MYSQL_CLI -e "SELECT address FROM vmail.forwardings where address='$ALIAS';" | grep -q "$ALIAS"
then
  $MYSQL_CLI -e "DELETE FROM vmail.forwardings WHERE address='$ALIAS';"
  echo "Removed forwarding for alias '$ALIAS'!"
else
  echo "Forwarding for alias '$ALIAS' do not exist!"
fi

if $MYSQL_CLI -e "SELECT address FROM vmail.alias where address='$ALIAS';" | grep -q "$ALIAS"
then
  # alias
  $MYSQL_CLI -e "DELETE FROM vmail.alias WHERE address='$ALIAS';"
  echo "Removed alias '$ALIAS'!"
else
  echo "Alias '$ALIAS' does not exist!"
fi

echo ''
