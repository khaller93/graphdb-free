#!/bin/bash

if [ -z "$1" ] ; then
	echo "GraphDB version must be specified as argument."
	exit 1
fi

DockerfileVersion="1.3.3"
GDB_VERSION="$1"

docker build --build-arg GDB_VERSION=${GDB_VERSION} \
	--build-arg DFILE_VERSION=${DockerfileVersion} \
	-t khaller/graphdb-free:${DockerfileVersion}-graphdb${GDB_VERSION} \
	.