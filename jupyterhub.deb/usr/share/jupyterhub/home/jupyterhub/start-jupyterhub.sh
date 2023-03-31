#!/bin/bash

if [ "$(id -un)" != "jupyterhub" ]
then
   echo "runs this as jupyterhub only."
   exit 1
fi

case "$1"
in
start) {

    if [ ! -r ~jupyterhub/etc/jupyterhub_config.py ]
    then
    mkdir -p ~jupyterhub/etc
    jupyterhub --generate-config -y=True -f ~jupyterhub/etc/jupyterhub_config.py
    fi

    (
        cat ~jupyterhub/etc/jupyterhub_config.py | grep -v "#jupyterhub-service#"
        echo "c.JupyterHub.spawner_class='sudospawner.SudoSpawner' #jupyterhub-service#"
        echo "c.JupyterHub.allow_named_servers=True #jupyterhub-service#"
        echo "c.JupyterHub.cleanup_proxy=False #jupyterhub-service#"
        echo "c.JupyterHub.cleanup_servers=False #jupyterhub-service#"
        echo "c.Spawner.start_timeout=120 #jupyterhub-service#"
        echo "c.Spawner.http_timeout=240 #jupyterhub-service#"
    ) > ~jupyterhub/etc/jupyterhub_config.py.work

    mv -f ~jupyterhub/etc/jupyterhub_config.py.work ~jupyterhub/etc/jupyterhub_config.py

    chmod g+x ~/.
    chmod -R g+rx .local

    #TODO make that extract out of the real env.
    export PYTHONPATH=/home/jupyterhub/.local/lib/python3.9/site-packages
    shift
    exec jupyterhub --debug -f ~jupyterhub/etc/jupyterhub_config.py ${1+"$@"}

} ;;

*) {
    if [ $(screen -ls | grep jupyterhub_serve | wc -l) -eq 0 ]
    then
       screen -dmS jupyterhub_serve $0 start ${1+"$@"}
    fi
} ;;
esac

