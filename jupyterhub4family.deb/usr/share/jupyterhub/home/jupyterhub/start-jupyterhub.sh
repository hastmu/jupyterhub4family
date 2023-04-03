#!/bin/bash

if [ "$(id -un)" != "jupyterhub" ]
then
   echo "runs this as jupyterhub only."
   exit 1
fi

function create_if_needed() {
    if [ ! -x "$1" ]
    then
        mkdir -p "$1"
    fi
}

case "$1"
in
start) {

    for item in ~jupyterhub/.local/bin ~jupyterhub/etc ~jupyterhub/node_modules/.bin
    do
        create_if_needed ${item}
    done

    export PATH=~/.local/bin:${PATH}
    export PATH=~/node_modules/.bin:${PATH}

    (
        # boot strap

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

        echo "- update bashrc..."
        ( cat ~jupyterhub/.bashrc | grep -v '#jupyterhub-service#' ; 
        echo "export PATH=~/.local/bin:\${PATH} #jupyterhub-service#" ;
        echo "export PATH=~/node_modules/.bin:\${PATH} #jupyterhub-service#" ;
        ) > ~jupyterhub/.bashrc.tmp
        mv -f ~jupyterhub/.bashrc.tmp ~jupyterhub/.bashrc

        echo "- check jupyterhub"
        if [ ! -x ~jupyterhub/.local/bin/jupyterhub ]
        then
            echo "- install local jupyterhub"
            pip3 install --user jupyterhub
        fi

        if [ ! -r ~jupyterhub/etc/jupyterhub_config.py ]
        then
            jupyterhub --generate-config -y=True -f ~jupyterhub/etc/jupyterhub_config.py
        fi

        echo "- set defaults..."
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


        echo "- check configurable-http-proxy"
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
        
        # self-signed certs
        echo "- check/create certs"
        if [ ! -e ~jupyterhub/etc/cert.crt ] || [ ! -e ~jupyterhub/etc/cert.key ]
        then
        openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes \
                    -out ~jupyterhub/etc/cert.crt -keyout ~jupyterhub/etc/cert.key \
                    -subj "/C=--/ST=--/L=--/O=--/OU=Family/CN=$(hostname -f)"
        fi
    ) | tee ~jupyterhub/bootstrap.log

    chmod g+x ~/.
    chmod -R g+rx .local

    #TODO make that extract out of the real env.
    export PYTHONPATH=/home/jupyterhub/.local/lib/python3.9/site-packages
    shift
    if [ -r ~jupyterhub/etc/cert.key ] && [ -r ~jupyterhub/etc/cert.crt ]
    then
       exec jupyterhub --debug -f ~jupyterhub/etc/jupyterhub_config.py \
              --ssl-key ~jupyterhub/etc/cert.key --ssl-cert ~jupyterhub/etc/cert.crt \
              ${1+"$@"}
    else
       exec jupyterhub --debug -f ~jupyterhub/etc/jupyterhub_config.py ${1+"$@"}
    fi

} ;;

*) {
    if [ $(screen -ls | grep jupyterhub_serve | wc -l) -eq 0 ]
    then
       screen -dmS jupyterhub_serve $0 start ${1+"$@"}
    fi
} ;;
esac

