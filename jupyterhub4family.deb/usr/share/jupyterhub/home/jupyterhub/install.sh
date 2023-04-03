#!/bin/bash

set -e

if [ "$(id -un)" != "jupyterhub" ]
then
   echo "runs this as jupyterhub only."
   exit 1
fi

echo "Jupyterhub - User part..."

# setup cron to start the service if needed.
echo "- update crontab"
set +e
( 
   (crontab -l || true) | grep -v '#jupyterhub-service#' ;
   echo "* * * * * /usr/share/jupyterhub/home/jupyterhub/start-jupyterhub.sh #jupyterhub-service#"
) | crontab
set -e

echo "- Info: first start at service account will bootstrap installation."
echo "Done"

