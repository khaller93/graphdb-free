# ---------------------------------------------
#  Extracting the GraphDB distribution
# ---------------------------------------------
FROM alpine:3.12 AS ZipExtractor

ARG GDB_VERSION

RUN apk add unzip
COPY "dist/graphdb-free-${GDB_VERSION}-dist.zip" dist/
RUN unzip -q "./dist/graphdb-free-${GDB_VERSION}-dist.zip" && \
		mkdir -p /opt && mv "graphdb-free-${GDB_VERSION}" /opt/graphdb

# ----------------------------------------------
#  Repository/SPARQL Initialization GoCompiler
# ----------------------------------------------
FROM golang:1.15.0-buster AS GoCompiler

RUN mkdir -p /binaries

# compiles program that initializes GraphDB repositories
COPY graphdb-repository-init graphdb-repository-init
WORKDIR graphdb-repository-init
RUN go build && \
	mv graphdb-repository-init /binaries/graphdb-repository-init

# compiles program that pre-queries SPARQL queries
COPY repo-presparql-query repo-presparql-query
WORKDIR repo-presparql-query
RUN go mod vendor && \
	go build && \
	mv repo-presparql-query /binaries/repo-presparql-query

# -----------------------------------------------
#  Main Image
# -----------------------------------------------
FROM openjdk:11-jdk-slim

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		iproute2 && \
	rm -rf /var/lib/apt/lists/*

LABEL maintainer="Kevin Haller <contact@kevinhaller.dev,kevin.haller@tuwien.ac.at>"

VOLUME /opt/graphdb/data
VOLUME /opt/graphdb/log
VOLUME /opt/graphdb/conf
VOLUME /opt/graphdb/work

EXPOSE 7200

RUN mkdir -p /opt/graphdb
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --from=GoCompiler /binaries/* /usr/local/bin/

ARG DFILE_VERSION="1.3.6"
ARG GDB_VERSION

LABEL version="${DFILE_VERSION}-graphdb${GDB_VERSION}"
LABEL description="Fresh new instance of GraphDB ${GDB_VERSION} (free version)."

COPY --from=ZipExtractor /opt/graphdb /opt/graphdb

ENTRYPOINT ["docker-entrypoint.sh"]

