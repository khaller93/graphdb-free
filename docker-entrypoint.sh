#!/bin/bash
set -e

graphdb-repository-init "/repository.init"
repo-presparql-query "/repository.init" &

exec /opt/graphdb/bin/graphdb "$@"