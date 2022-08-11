#!/bin/bash

set -e

queue=$(postqueue -p)

echo ''

if echo "$queue" | grep -q 'empty'
then
  echo 'NO MAILS IN QUEUE!'
  echo 'Nothing to do.'
else
  echo 'MAILS IN QUEUE:'
  echo ''
  echo '####################'
  echo ''
  echo "$queue"
  echo ''
  echo '####################'
  echo ''

  read -r -p 'Provide the QUEUE-ID to remove from the queue: ' queue_id

  echo ''
  postsuper -d "$queue_id"
fi

echo ''
