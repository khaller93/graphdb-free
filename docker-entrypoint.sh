#!/bin/sh
set -e

USER="${GDB_USER:=root}"

mkdir -p /repository.init
mkdir -p /tmp/toLoad.tmp

if [ "$USER" != "root" -a "$USER" != "0" ]; then
  USER_PWD=$(cat /etc/passwd | grep -e "(^$USER:|:$USER:)" || true)
  if [ -z "$USER_PWD" ]; then
    if [ $(expr "$USER" : "^[0-9]*$") -eq 0 ]; then
      useradd --no-create-home $USER
    else
      useradd --no-create-home --uid $USER graphdb-user 
      USER="graphdb-user"
    fi
  fi
  set-ownership $USER
fi

exec tini -g setpriv -- --reuid=$USER --inh-caps=-all run-graphdb "$@"