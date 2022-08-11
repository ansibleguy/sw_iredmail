#!/bin/bash
# Ansible managed
# ansibleguy.sw_iredmail

# see: https://docs.iredmail.org/sql.add.alias.domain.html

set -e

MYSQL_CLI='mysql -uroot --socket {{ IRM_CONFIG.database.socket }}'

echo ''

if [ -z "$1" ]
then
  echo 'To filter the output by domain - provide it as argument.'

  echo ''
  echo 'EXISTING DOMAIN-ALIASES:'
  $MYSQL_CLI -e "SELECT alias_domain, target_domain FROM vmail.alias_domain;"
else
  FILTER_DOMAIN="$1"

  echo 'EXISTING DOMAIN-ALIASES WITH FILTER-SOURCE:'
  $MYSQL_CLI -e "SELECT alias_domain, target_domain FROM vmail.alias_domain WHERE alias_domain='$FILTER_DOMAIN';"

  echo ''
  echo 'EXISTING DOMAIN-ALIASES WITH FILTER-TARGET:'
  $MYSQL_CLI -e "SELECT alias_domain, target_domain FROM vmail.alias_domain WHERE target_domain='$FILTER_DOMAIN';"
fi

echo ''
