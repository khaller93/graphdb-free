#!/bin/bash
set -e

graphdb-repository-init "/repository.init"

exec /opt/graphdb/bin/graphdb "$@"