#!/bin/bash
# {{ ansible_managed }}
# ansibleguy.sw_iredmail

# see: https://docs.iredmail.org/sql.create.mail.alias.html

set -e

if [ -z "$1" ] || [ -z "$2" ]
then
  echo ''
  echo 'You need to supply the following arguments:'
  echo '  1 > mail domain'
  echo '  2 > dkim selector (date will be appended)'
  echo 'Example: dkim_add.sh template.ansibleguy.net mail'
  echo ''
  exit 1
fi

DATE="$(date '+%Y%m%d')"
DOMAIN="$1"
SELECTOR="$2-$DATE"
TTL_H=24
FILE_KEY="/var/lib/dkim/$DOMAIN.$SELECTOR.pem"
FILE_CNF='/etc/amavis/conf.d/50-user'
INSERT_AFTER_KEY='# Add dkim_key here'
INSERT_AFTER_SIG='    # Per-domain dkim key'
SIGNATURE="\ \ \ \ '$DOMAIN' => { d => '$DOMAIN', a => 'rsa-sha256', ttl => $TTL_H*3600 },"
changed=false

echo ''

function add_key {
  amavisd-new -c "$FILE_CNF" genrsa "$FILE_KEY" 4096 2>/dev/null
  chmod 640 "$FILE_KEY"
  chown amavis:amavis "$FILE_KEY"
  sed -i "/^$INSERT_AFTER_KEY/a dkim_key('$DOMAIN', '$SELECTOR', '$FILE_KEY');" "$FILE_CNF"
  sed -i "/^$INSERT_AFTER_SIG/a $SIGNATURE" "$FILE_CNF"
  echo 'Added new key!'
  changed=true
}

if cat "$FILE_CNF" | grep "dkim_key('$DOMAIN'" -q
then
  echo "Found configured dkim-key for domain '$DOMAIN'!"
  read -r -p 'Do you want to replace it? [YES/no]' user_prompt

  if [ -z "$user_prompt" ] || [[ "$user_prompt" == 'y' ]] || [[ "$user_prompt" == 'YES' ]]
  then
    sed -i "/dkim_key('$DOMAIN'/d" "$FILE_CNF"
    sed -i "/^    '$DOMAIN' => { d => '$DOMAIN',/d" "$FILE_CNF"
    rm -f "$FILE_KEY"
    echo 'Removed existing keys!'
    add_key
  fi
else
  rm -f "$FILE_KEY"
  add_key
fi

echo ''
echo 'DKIM RECORD KEY:'
echo "$SELECTOR._domainkey.$DOMAIN"
echo ''
echo 'DKIM RECORD TTL:'
echo "$TTL_H h"
echo ''
echo 'DKIM RECORD VALUE:'
amavisd-new -c "$FILE_CNF" showkeys "$DOMAIN" 2>/dev/null | grep 'v=DKIM1' -A 12 | tr -d '\n' | tr -d "[:space:]" | tr -d '"' | tr -d  ')'
echo ''
echo ''

if [[ "$changed" = true ]]
then
  read -r -p 'Do you want to active the new keys now? You may get temporary problems as the new DNS-records do not yet exist.. [YES/no]' user_prompt

  if [ -z "$user_prompt" ] || [[ "$user_prompt" == 'y' ]] || [[ "$user_prompt" == 'YES' ]]
  then
    systemctl restart amavis.service
    echo 'Restarted service.'
  else
    echo "You will have to restart the service manually later on: 'systemctl restart amavis.service'"
  fi
else
  echo 'Config up-to-date.'
fi
echo ''
