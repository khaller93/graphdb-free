# ---------------------------------------------
#  Extracting the GraphDB distribution
# ---------------------------------------------
FROM alpine:3.12 AS ZipExtractor

ARG GDB_VERSION

RUN apk add unzip
COPY "dist/graphdb-${GDB_VERSION}-dist.zip" dist/
RUN unzip -q "./dist/graphdb-${GDB_VERSION}-dist.zip" \
	&& mv "graphdb-${GDB_VERSION}" /opt/graphdb \
	&& rm -rf dist

# ----------------------------------------------
#  Repository/SPARQL Initialization GoCompiler
# ----------------------------------------------
FROM golang:1.18-buster AS GoCompiler

RUN mkdir -p /binaries

# compiles program that initializes GraphDB repositories
COPY graphdb-repository-init /opt/go/app/graphdb-repository-init
WORKDIR /opt/go/app/graphdb-repository-init
RUN go mod vendor \
	&& go build \
	&& mv graphdb-repository-init /binaries/graphdb-repository-init

# compiles program that pre-queries SPARQL queries
COPY repo-presparql-query /opt/go/app/repo-presparql-query
WORKDIR /opt/go/app/repo-presparql-query
RUN go mod vendor \
	&& go build \
	&& mv repo-presparql-query /binaries/repo-presparql-query

RUN rm -rf /opt/go/app

# -----------------------------------------------
#  Main Image
# -----------------------------------------------
FROM openjdk:11-jdk-slim

LABEL maintainer="Kevin Haller <contact@kevinhaller.dev>"

ENV PATH="$PATH:/opt/graphdb/bin"

VOLUME /opt/graphdb/data
VOLUME /opt/graphdb/log
VOLUME /opt/graphdb/conf
VOLUME /opt/graphdb/work

EXPOSE 7200
EXPOSE 7300

COPY set-ownership.sh /usr/bin/set-ownership
COPY run-graphdb.sh /usr/bin/run-graphdb
COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY --from=GoCompiler /binaries/* /usr/bin/

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		gosu \
		iproute2 \
		tini \
	&& rm -rf /var/lib/apt/lists/*

ARG DFILE_VERSION
ARG GDB_VERSION

LABEL version="${DFILE_VERSION}-graphdb${GDB_VERSION}"
LABEL description="Fresh new instance of GraphDB ${GDB_VERSION} (free version)."

COPY --from=ZipExtractor /opt/graphdb /opt/graphdb

ENTRYPOINT ["docker-entrypoint.sh"]
