FROM golang:1.13-alpine AS repoInitCompiler

COPY graphdb-repository-init graphdb-repository-init
WORKDIR graphdb-repository-init
RUN GOOS=linux go build

RUN mkdir -p /binaries && mv graphdb-repository-init /binaries/graphdb-repository-init

# --------------------
#   Main Image
# --------------------

FROM openjdk:8-jre

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

COPY --from=repoInitCompiler /binaries/graphdb-repository-init /usr/local/bin/graphdb-repository-init

ARG DFILE_VERSION="1.3.0"
ARG GDB_VERSION

LABEL maintainer="Kevin Haller <keivn.haller@outofbits.com>"
LABEL version="${DFILE_VERSION}-graphdb${GDB_VERSION}"
LABEL description="Fresh new instance of GraphDB ${GDB_VERSION} (free version)."

# install GraphDB
COPY dist/graphdb-free-${GDB_VERSION}-dist.zip dist/
RUN unzip -q ./dist/graphdb-free-${GDB_VERSION}-dist.zip && \
		mv graphdb-free-${GDB_VERSION} /opt/graphdb && \
		rm -rf dist

ENTRYPOINT ["docker-entrypoint.sh"]