#!/bin/bash
# Ansible managed
# ansibleguy.sw_iredmail

# see: https://docs.iredmail.org/sql.add.alias.domain.html

set -e

MYSQL_CLI='mysql -uroot --socket {{ IRM_CONFIG.database.socket }}'

if [ -z "$1" ] || [ -z "$2" ]
then
  echo ''
  echo 'You need to supply the following arguments:'
  echo '  1 > alias domain'
  echo '  2 > target domain'
  echo 'Example: domain_alias_remove.sh test.ansibleguy.net template.ansibleguy.net'
  echo ''
  exit 1
fi

ALIAS="$1"
TARGET="$2"

echo ''

# checking if domain-alias already exists
if $MYSQL_CLI -e "SELECT alias_domain FROM vmail.alias_domain WHERE alias_domain='$ALIAS';" | grep -q "$ALIAS"
then
  existing_target=$($MYSQL_CLI -e "SELECT target_domain FROM vmail.alias_domain WHERE alias_domain='$ALIAS';" | sed '2p;d')
  if echo "$existing_target" | grep -q "$TARGET"
  then
    $MYSQL_CLI -e "DELETE FROM vmail.alias_domain WHERE target_domain='$TARGET' AND alias_domain='$ALIAS';"
    echo "Removed domain alias from '$ALIAS' to '$TARGET'!"
  else
    echo "Domain alias from '$ALIAS' to '$TARGET' does not exists!"
    echo "Currently from '$ALIAS' to '$existing_target'."
  fi
else
  echo "Domain '$ALIAS' has no domain alias configured."
fi

echo ''
