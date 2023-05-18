#!/bin/sh
if [ -z "$1" ]; then
  echo "error: you must specify the user"
  echo "usage: $0 <user>"
  exit 1
fi

USER=$1

chown $USER -R /opt/graphdb
chown $USER -R /tmp/graphdb

if [ -d "/repository.init" ]; then
  chown $USER -R /repository.init || true
fi
