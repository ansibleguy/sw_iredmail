#!/bin/bash
# {{ ansible_managed }}
# ansibleguy.sw_iredmail

# see: https://doc.dovecot.org/admin_manual/migrating_mailboxes/#migrating-mailboxes-imapc
# see: man doveadm-backup

set -e

MODE='backup'  # or 'sync'
# make sure you understand what that modes are doing
# basically:
#   backup => pulling all mails from source; deleting mails in destination that are not in source
#   sync => pulling all mails from source; pushing all new mails from destination; NEEDS TO BE TESTED! MAY MAKE MAJOR PROBLEMS!!!

# source server:port
# source user/mail
# source pwd
# dest user if other

PORT=993
HARDCODED='-o imapc_features=rfc822.size -o mail_fsync=never'
ADD_ARGS=''  # per example: '-o ssl_client_ca_file=/etc/ssl/myCa.pem'
DEBUG=false
HOSTS_WO_BASIC_AUTH='outlook.office365.com'

echo ''

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
  echo 'You need to supply the following arguments:'
  echo '  1 > source server (default port=993)'
  echo '  2 > source mail/user'
  echo '  3 > source password'
  echo '  4 > destination mail/user (optional => if it differs from source-user)'
  echo "Example: import_via_imap.sh template.ansibleguy.net:143 contact@ansibleguy.net 'super\$ecure!' guy@ansibleguy.net"
  echo ''
  exit 1
fi

HOST="$1"
SOURCE_USER="$2"
SOURCE_PWD="$3"

if [ -z "$4" ]
then
  DEST_USER="$SOURCE_USER"
else
  DEST_USER="$4"
fi

if echo "$HOST" | grep ':' -q
then
  PORT=$(echo "$HOST" | cut -d ':' -f2)
  HOST=$(echo "$HOST" | cut -d ':' -f1)
fi

if echo "$HOST" | grep -qE "$HOSTS_WO_BASIC_AUTH"
then
  echo "Your '$HOST' does not support basic authentication!"
  echo 'This migration will not work for such servers..'
  echo 'You might need to do a workaround:'
  echo '  1. Export your existing mails from a mail-client'
  echo '  2. Add your new mailbox to the mail-client using IMAP.'
  echo '  3. Import your existing mails into the new mailbox.'
  echo ''
  exit 1
fi

if [[ "$PORT" == 143 ]]
then
  SSL='starttls'
else
  SSL='imaps'
fi

if [[ "$DEBUG" == true ]]
then
  VERBOSITY='-Dv'
else
  VERBOSITY='-v'
fi

if doveadm user "$DEST_USER" | grep "doesn't exist" -q
then
  echo "ERROR: Destination user '$DEST_USER' does not exist yet!"
  echo 'You need to add the user before importing mails!'
  echo "You can do so at: 'https://YOUR-MAIL-DOMAIN/iredadmin'"
  echo ''
  exit 1
fi

IMAP="doveadm $VERBOSITY $HARDCODED $ADD_ARGS -o imapc_host=$HOST -o imapc_port=$PORT -o imapc_ssl=$SSL -o imapc_user=$SOURCE_USER -o imapc_password='$SOURCE_PWD'"

echo "Using connection '$SSL://$HOST:$PORT'"
echo "Testing credentials for '$SOURCE_USER'"
echo "$IMAP -o mail_location=imapc: mailbox list"
echo ''
if ! $IMAP -o mail_location=imapc: mailbox list
then
  echo ''
  echo "ERROR: Authentication FAILED for user '$SOURCE_USER'!"
  if [[ "$DEBUG" == true ]]
  then
    echo "Using password: '$SOURCE_PWD'"
  fi
  echo 'Check that the credentials are correct and IMAP is enabled on the source-host!'
  echo ''
  exit 1
fi

echo "Starting migration '$SOURCE_USER@$HOST' => '$DEST_USER@$(hostname)'"
echo ''

if $IMAP $MODE -R -u "$DEST_USER" imapc:
then
  echo ''
  echo "Migration finished sucessfully: '$SOURCE_USER@$HOST' => '$DEST_USER@$(hostname)'"
else
  echo ''
  echo "Migration FAILED: '$SOURCE_USER@$HOST' => '$DEST_USER@$(hostname)'"
  echo ''
  exit 1
fi

echo ''
