#!/bin/bash
set -e

mkdir -p /data
mkdir -p /opt/graphdb/data

if [ ! -f "/opt/graphdb/data/loading.lock" ] ; then
	if [ ! -z "$CONF_REPOSITORY_ID" ] ; then
		if [ ! -f "/data/config.ttl" ] ; then
			./gen-graphdb-config.sh > "/data/config.ttl"
		fi
		echo "Loading initial data ..."
		./load-initial-data.sh "/data/config.ttl" "/data/toLoad"
		touch "/opt/graphdb/data/loading.lock"
		echo "Loading initial data done."
	fi
fi
if [ ! -f "/opt/graphdb/data/fts.lock" ] ; then
	if [ ! -z ${CONF_ENABLE_FTS} -a ${CONF_ENABLE_FTS} = "true" ] ; then
		echo "Creating FTS index ..."
		./init-fulltext-index.sh ${CONF_REPOSITORY_ID} ${CONF_FTS_INDEX_NAME}
		touch "/opt/graphdb/data/fts.lock"
		echo "Creating FTS index done."
	fi
fi

exec /opt/graphdb/bin/graphdb "$@"