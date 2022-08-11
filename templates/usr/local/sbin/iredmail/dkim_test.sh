#!/bin/bash
# {{ ansible_managed }}
# ansibleguy.sw_iredmail

# see: https://docs.iredmail.org/sql.create.mail.alias.html

set -e

FILE_CNF='/etc/amavis/conf.d/50-user'

echo ''

if [ -z "$1" ]
then
  echo 'To filter the output by domain - provide it as argument.'

  echo ''
  echo 'TESTING ALL KEYS:'
  amavisd-new -c "$FILE_CNF" testkeys 2>/dev/null
else
  FILTER_DOMAIN="$1"

  echo "TESTING KEY FOR DOMAIN '$FILTER_DOMAIN'"
  amavisd-new -c "$FILE_CNF" testkeys "$FILTER_DOMAIN" 2>/dev/null
fi

echo ''
