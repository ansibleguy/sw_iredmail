#!/bin/bash
# {{ ansible_managed }}
# ansibleguy.sw_iredmail

# see: https://docs.iredmail.org/sql.user.mail.forwarding.html | https://docs.iredmail.org/sql.create.catch-all.html

set -e

MYSQL_CLI='mysql -uroot --socket {{ IRM_CONFIG.database.socket }}'

if [ -z "$1" ] || [ -z "$2" ]
then
  echo ''
  echo 'You need to supply the following arguments:'
  echo "  1 > source email or domain (domain for a 'catch-all')"
  echo '  2 > target user or email'
  echo 'Example: forwarding_add.sh test@template.ansibleguy.net webmaster@ansibleguy.net'
  echo ''
  exit 1
fi

SOURCE="$1"
if ! echo "$1" | grep -q '@'
then
  DOMAIN_SRC="$SOURCE"
else
  DOMAIN_SRC=$(echo "$SOURCE" | cut -d '@' -f2)
fi

if echo "$2" | grep -q '@'
then
  TARGET="$2"
  DOMAIN_DEST=$(echo "$TARGET" | cut -d '@' -f2)
else
  TARGET="$2@$DOMAIN_SRC"
  DOMAIN_DEST="$DOMAIN_SRC"
fi

echo ''

created=false

# forwarding
if $MYSQL_CLI -e "SELECT forwarding FROM vmail.forwardings where address='$SOURCE';" | grep -q "$TARGET"
then
  echo "Forwarding from '$SOURCE' to '$TARGET' already exists!"
else
  $MYSQL_CLI -e "INSERT INTO vmail.forwardings (address, forwarding, domain, dest_domain, is_list, active) VALUES ('$SOURCE', '$TARGET', '$DOMAIN_SRC', '$DOMAIN_DEST', 1, 1);"
  created=true
fi

echo ''
if [[ "$created" = true ]]
then
  echo "Created forwarding from '$SOURCE' to '$TARGET'!"
else
  echo 'Config up-to-date.'
fi
echo ''
