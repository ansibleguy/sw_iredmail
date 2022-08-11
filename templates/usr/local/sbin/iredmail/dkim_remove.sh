#!/bin/bash
# {{ ansible_managed }}
# ansibleguy.sw_iredmail

# see: https://docs.iredmail.org/sql.create.mail.alias.html

set -e

if [ -z "$1" ]
then
  echo ''
  echo 'You need to supply the following arguments:'
  echo '  1 > mail domain'
  echo 'Example: dkim_remove.sh template.ansibleguy.net'
  echo ''
  exit 1
fi

DOMAIN="$1"
FILE_KEY="/var/lib/dkim/$DOMAIN.*.pem"
FILE_CNF='/etc/amavis/conf.d/50-user'

echo ''

if cat "$FILE_CNF" | grep "dkim_key('$DOMAIN'" -q
then
  sed -i "/dkim_key('$DOMAIN'/d" "$FILE_CNF"
  sed -i "/^    '$DOMAIN' => { d => '$DOMAIN',/d" "$FILE_CNF"
  rm -f $FILE_KEY
  echo 'Removed existing keys!'

  read -r -p 'Do you want to active the changes now? [YES/no]' user_prompt

  if [ -z "$user_prompt" ] || [[ "$user_prompt" == 'y' ]] || [[ "$user_prompt" == 'YES' ]]
  then
    systemctl restart amavis.service
    echo 'Restarted service.'
  else
    echo "You will have to restart the service manually later on: 'systemctl restart amavis.service'"
  fi
else
  echo "No key found domain '$DOMAIN' - nothing to do."
fi

echo ''
