#!/bin/bash

set -e

if [ "$(id -un)" != "jupyterhub" ]
then
   echo "runs this as jupyterhub only."
   exit 1
fi

echo "Jupyterhub - User part..."

( cat ~jupyterhub/.bashrc | grep -v '#jupyterhub-service#' ; 
  echo "export PATH=~/.local/bin:\${PATH} #jupyterhub-service#" ;
  echo "export PATH=~/node_modules/.bin:\${PATH} #jupyterhub-service#" ;
   ) > ~jupyterhub/.bashrc.tmp

mv -f ~jupyterhub/.bashrc.tmp ~jupyterhub/.bashrc

if [ ! -x ~jupyterhub/.local/bin/jupyterhub ]
then
   echo "- install local jupyterhub"
   pip3 install --user jupyterhub
fi

if [ ! -x ~/node_modules/.bin/configurable-http-proxy ]
then
   echo "- install local configurable-http-proxy"
   npm install configurable-http-proxy
fi

if [ ! -x ~jupyterhub/git.wa/sudospawner ]
then
   echo "- get sudospawner from git..."
   mkdir ~jupyterhub/git.wa
   cd ~jupyterhub/git.wa
   git clone https://github.com/jupyterhub/sudospawner.git
   echo "- installing sudospawner..."
   cd ~jupyterhub/git.wa/sudospawner ; pip3 install --user -e .
   cd
else
   echo "- update sudospawner from git..."
   cd ~jupyterhub/git.wa/sudospawner
   git config pull.ff only
   git pull
   # TODO update install if there was an update
fi

echo "- create link:start-jupyterhub.sh"
if [ ! -h ~jupyterhub/.local/bin/start-jupyterhub.sh ]
then
   ln -s /usr/share/jupyterhub/home/jupyterhub/start-jupyterhub.sh ~jupyterhub/.local/bin/start-jupyterhub.sh
fi

echo "- create link:sudospawner-singleuser"
if [ ! -h ~jupyterhub/.local/bin/sudospawner-singleuser ]
then
   ln -s /usr/share/jupyterhub/home/jupyterhub/start-user-session.sh ~jupyterhub/.local/bin/sudospawner-singleuser
fi

# setup cron to start the service if needed.
echo "- update crontab"
set +e
( 
   (crontab -l || true) | grep -v '#jupyterhub-service#' ;
   echo "* * * * * /usr/share/jupyterhub/home/jupyterhub/start-jupyterhub.sh #jupyterhub-service#"
) | crontab
set -e

# self-signed certs
echo "- check/create certs"
if [ ! -e ~jupyterhub/etc/cert.crt ] || [ ! -e ~jupyterhub/etc/cert.key ]
then
   openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes \
               -out ~jupyterhub/etc/cert.crt -keyout ~jupyterhub/etc/cert.key \
               -subj "/C=--/ST=--/L=--/O=--/OU=Family/CN=$(hostname -f)"
fi

echo "Done"

