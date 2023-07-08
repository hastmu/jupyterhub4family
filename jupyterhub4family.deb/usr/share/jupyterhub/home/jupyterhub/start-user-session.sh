#!/bin/bash

# TODO precheck
( cat ~/.bashrc | grep -v '#jupyterhub-service#' ; 
  echo "export PATH=~/.local/bin:\${PATH} #jupyterhub-service#"
   ) > ~/.bashrc.tmp
mv -f ~/.bashrc.tmp ~/.bashrc

export PATH=~/.local/bin:${PATH}
export PATH=$(echo ${PATH} | tr ":" "\n" | grep -v "^/home/jupyterhub" | tr "\n" ":")

declare -A CFG
CFG[jupyterhub-singleuser]="jupyterhub"
CFG[jupyter-lab]="jupyterlab"
CFG[jupyter-notebook]="notebook"

for item in ${!CFG[@]}
do
   if [ $(pip3 freeze | grep "^${CFG[${item}]}=" | wc -l) -eq 0 ]
   then
      PIP_BREAK_SYSTEM_PACKAGES=1 pip3 install --user ${CFG[${item}]}
   fi
done

exec jupyterhub-singleuser ${1+"$@"}
