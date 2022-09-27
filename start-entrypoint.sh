#!/bin/bash
USER="root"

if [ -n "$GDB_USER" ]; then
    if [[ "$GDB_USER" =~ ^[0-9]+$ ]]; then
        USER=graphdb
        adduser graphdb --uid $GDB_USER --disabled-login --gecos "" > /dev/null
    else
        USER=$GDB_USER
        USER_ENTRY=$(cat /etc/passwd | grep -op "^${GDB_USER}:")
        if [ -z $USER_ENTRY ]; then
            adduser $USER --disabled-login --gecos "" > /dev/null
        fi
    fi
    chown $USER -R /opt/graphdb/data /opt/graphdb/log /opt/graphdb/conf /opt/graphdb/work
    if [ -d /repository.init ]; then
        chown $USER -R /repository.init
    fi
fi

cmd=$( printf 'run-graphdb ' "$@" )
exec runuser $USER -c $cmd