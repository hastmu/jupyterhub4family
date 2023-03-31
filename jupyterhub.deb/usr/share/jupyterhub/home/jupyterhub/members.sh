#!/bin/bash

set -e

if [ $(/usr/bin/id -u) -ne 0 ]
then
   exec /usr/bin/sudo /usr/share/jupyterhub/home/jupyterhub/members.sh ${1+"$@"}
fi

case "$1"
in
add) {
    exec /usr/sbin/adduser "$2" jupyterhub
} ;;

remove) {
    exec /usr/sbin/deluser "$2" jupyterhub
} ;;

show) {
    exec /usr/bin/getent group jupyterhub
} ;;

*) {
    echo "usage: sudo $0 [add <user>|remove <user>|show]"
    exit 1
} ;;
esac
