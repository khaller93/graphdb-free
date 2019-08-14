#!/bin/sh
set -e

if [ -f $1 ]; then
	if [ ! -z "$2" -a -d $2 ]; then
		/opt/graphdb/bin/loadrdf $2 -c $1 -m parallel -v -p --force
	else
		echo "Data directory '$2' not found or specified."
		/opt/graphdb/bin/loadrdf -c $1 -m parallel -v -p --force
	fi
else
	echo "Creating repository failed, because no configuration file found at '${1}'."
	exit 1
fi