#!/bin/bash
# {{ ansible_managed }}
# ansibleguy.sw_iredmail

# see: https://docs.iredmail.org/sql.create.mail.alias.html

set -e

MYSQL_CLI='mysql -uroot --socket {{ IRM_CONFIG.database.socket }}'

if [ -z "$1" ] || [ -z "$2" ]
then
  echo ''
  echo 'You need to supply the following arguments:'
  echo '  1 > alias email'
  echo '  2 > target user or email'
  echo '  3 > access policy (optional) [PUBLIC/domain/subdomain/membersonly/moderatorsonly/membersandmoderatorsonly]'
  echo 'Example: alias_add.sh test@template.ansibleguy.net webmaster@ansibleguy.net domain'
  echo ''
  exit 1
fi

if ! echo "$1" | grep -q '@'
then
  echo 'The provided alias is no valid email address!'
  echo ''
  exit 1
fi

ALIAS="$1"
DOMAIN_SRC=$(echo "$ALIAS" | cut -d '@' -f2)

if echo "$2" | grep -q '@'
then
  TARGET="$2"
  DOMAIN_DEST=$(echo "$TARGET" | cut -d '@' -f2)
else
  TARGET="$2@$DOMAIN_SRC"
  DOMAIN_DEST="$DOMAIN_SRC"
fi

if [ -z "$3" ] || echo "$3" | grep -Evq 'public|domain|subdomain|membersonly|moderatorsonly|membersandmoderatorsonly'
then
  POLICY='public'
else
  POLICY="$3"
fi

# alias
$MYSQL_CLI -e "INSERT INTO vmail.alias (address, domain, active) VALUES ('$ALIAS', '$DOMAIN_SRC', 1);"
# forwarding
$MYSQL_CLI -e "INSERT INTO vmail.forwardings (address, forwarding, domain, dest_domain, is_list, active) VALUES ('$ALIAS', '$TARGET', '$DOMAIN_SRC', '$DOMAIN_DEST', 1, 1);"
# access policy
$MYSQL_CLI -e "UPDATE vmail.alias SET accesspolicy='$POLICY' WHERE address='$ALIAS';"

echo "Created forwarding from '$ALIAS' to '$TARGET' with access-policy '$POLICY'!"
echo ''
