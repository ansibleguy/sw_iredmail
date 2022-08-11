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
  echo 'Example: dkim_show.sh template.ansibleguy.net'
  echo ''
  exit 1
fi

DOMAIN="$1"
FILE_CNF='/etc/amavis/conf.d/50-user'

SELECTOR=$(cat "$FILE_CNF" | grep -m1 "dkim_key('$DOMAIN'" | cut -d "'" -f4)
TTL_RAW=$(cat "$FILE_CNF" | grep -m1 "{ d => '$DOMAIN'" | cut -d " " -f16)
TTL_H=$((($TTL_RAW) / 3600))

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
