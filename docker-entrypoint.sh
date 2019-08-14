#!/bin/bash
set -e

mkdir -p /data
mkdir -p /opt/graphdb/data

if [ ! -f "/opt/graphdb/data/loading.lock" ] ; then
	if [ ! -f "/data/config.ttl" ] ; then
		./gen-graphdb-config.sh > "/data/config.ttl"
	fi
	echo "Loading initial data ..."
	./load-initial-data.sh "/data/config.ttl" "/data/toLoad"
	touch "/opt/graphdb/data/loading.lock"
	echo "Loading initial data done."	
fi
if [ ! -f "/opt/graphdb/data/fts.lock" ] ; then
	echo "Creating FTS index ..."
	./init-fulltext-index.sh ${CONF_ENABLE_FTS} ${CONF_REPOSITORY_ID} ${CONF_FTS_INDEX_NAME}
	touch "/opt/graphdb/data/fts.lock"
	echo "Creating FTS index done."
fi

exec /opt/graphdb/bin/graphdb "$@"