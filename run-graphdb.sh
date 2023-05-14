#!/bin/sh
set -e

graphdb-repository-init "/repository.init"
repo-presparql-query "/repository.init" &

graphdb "$@"