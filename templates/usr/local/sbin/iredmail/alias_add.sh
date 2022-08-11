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

echo ''

created=false
alias_exists=false

# alias
if $MYSQL_CLI -e "SELECT address FROM vmail.alias where address='$ALIAS';" | grep -q "$ALIAS"
then
  echo "Alias '$ALIAS' is already in use!"
  alias_exists=true
else
  $MYSQL_CLI -e "INSERT INTO vmail.alias (address, domain, active) VALUES ('$ALIAS', '$DOMAIN_SRC', 1);"
  created=true
fi

# forwarding
existing_target=$($MYSQL_CLI -e "SELECT forwarding FROM vmail.forwardings where address='$ALIAS';" | sed '2p;d')
if echo "$existing_target" | grep -q "$TARGET"
then
  echo "Forwarding from '$ALIAS' to '$TARGET' already exists!"
elif [[ "$alias_exists" = true ]]
then
  echo 'Forwarding ALREADY EXISTS!'
  echo "Currently from '$ALIAS' to '$existing_target'."
  echo 'Delete it before re-creating it.'
  echo ''
  exit 1
else
  $MYSQL_CLI -e "INSERT INTO vmail.forwardings (address, forwarding, domain, dest_domain, is_list, active) VALUES ('$ALIAS', '$TARGET', '$DOMAIN_SRC', '$DOMAIN_DEST', 1, 1);"
  created=true
fi

# access policy
if ! $MYSQL_CLI -e "SELECT accesspolicy from vmail.alias where address='$ALIAS';" | grep -q "$POLICY"
then
  $MYSQL_CLI -e "UPDATE vmail.alias SET accesspolicy='$POLICY' WHERE address='$ALIAS';"
  created=true
  if [[ "$alias_exists" = true ]]
  then
    echo 'Updated access policy.'
  fi
fi

echo ''
if [[ "$created" = true ]]
then
  echo "Created/updated forwarding from '$ALIAS' to '$TARGET' with access-policy '$POLICY'!"
else
  echo 'Config up-to-date.'
fi
echo ''
