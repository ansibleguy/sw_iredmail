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
  echo 'Example: domain_alias_add.sh test.ansibleguy.net template.ansibleguy.net'
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
    echo "Domain alias from '$ALIAS' to '$TARGET' already exists!"
  else
    echo 'Domain alias ALREADY EXISTS!'
    echo "Currently '$ALIAS' to '$existing_target'."
    echo 'Delete it before creating another.'
    echo ''
    exit 1
  fi
else
  if $MYSQL_CLI -e "SELECT target_domain FROM vmail.alias_domain WHERE alias_domain='$TARGET';" | grep -q "$ALIAS"
  then
    echo 'ERROR: FORWARDING LOOP!'
    echo "Cannot create domain alias from '$ALIAS' to '$TARGET' as '$TARGET' is already pointing to '$ALIAS'!"
    echo ''
    exit 1
  else
    $MYSQL_CLI -e "INSERT INTO vmail.alias_domain (alias_domain, target_domain) VALUES ('$ALIAS', '$TARGET');"
    echo "Created domain alias from '$ALIAS' to '$TARGET'!"
  fi
fi

echo ''
