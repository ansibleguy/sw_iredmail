#!/bin/bash
# {{ ansible_managed }}
# ansibleguy.sw_iredmail

set -e

MYSQL_CLI='mysql -uroot --socket {{ IRM_CONFIG.database.socket }}'

echo ''

if [ -z "$1" ]
then
  echo 'To filter the output by domain - provide it as argument.'

  echo ''
  echo 'EXISTING ALIASES:'
  $MYSQL_CLI -e 'SELECT address FROM vmail.alias;'

  echo ''
  echo 'EXISTING FORWARDINGS:'
  $MYSQL_CLI -e 'SELECT address, forwarding FROM vmail.forwardings;'

else
  FILTER_DOMAIN="$1"

  echo 'EXISTING ALIASES:'
  $MYSQL_CLI -e "SELECT address FROM vmail.alias where domain='$FILTER_DOMAIN';"

  echo ''
  echo 'EXISTING FORWARDINGS WITH FILTER-SOURCE:'
  $MYSQL_CLI -e "SELECT address, forwarding FROM vmail.forwardings where domain='$FILTER_DOMAIN';"

  echo ''
  echo 'EXISTING FORWARDINGS WITH FILTER-TARGET:'
  $MYSQL_CLI -e "SELECT address, forwarding FROM vmail.forwardings where dest_domain='$FILTER_DOMAIN';"
fi

echo ''
