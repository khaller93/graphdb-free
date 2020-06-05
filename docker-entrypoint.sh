#!/bin/bash
set -e
set -x

graphdb-repository-init "/repository.init"

exec /opt/graphdb/bin/graphdb "$@"