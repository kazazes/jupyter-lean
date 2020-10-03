#!/usr/bin/env bash

cd "$HOME" || exit 1
if [ ! -d 'Notebooks' ]; then
  mkdir Notebooks
fi

if [ ! -f 'Notebooks/config.json' ]; then
  cat >> Notebooks/config.json <<EOL
    {
      'data-folder':  '$HOME/data/',
      'composer-dll-directory':  '',
      'algorithm-language': 'Python',
      'messaging-handler':  'QuantConnect.Messaging.Messaging',
      'job-queue-handler': 'QuantConnect.Queues.JobQueue',
      'api-handler':  'QuantConnect.Api.Api'
    }
EOL
fi
