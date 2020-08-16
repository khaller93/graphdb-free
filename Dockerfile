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

# --------------------
#     Main Image
# --------------------
FROM openjdk:11-buster

RUN apt -qq update && apt install -qq unzip -y

# entrypoint shell script for starting GraphDB
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
# move the executables binaries from the compilation over
COPY --from=GoCompiler /binaries/* /usr/local/bin/

ARG DFILE_VERSION="1.3.3"
ARG GDB_VERSION

LABEL maintainer="Kevin Haller <keivn.haller@outofbits.com>"
LABEL version="${DFILE_VERSION}-graphdb${GDB_VERSION}"
LABEL description="Fresh new instance of GraphDB ${GDB_VERSION} (free version)."

# install GraphDB
COPY dist/graphdb-free-${GDB_VERSION}-dist.zip dist/
RUN unzip -q ./dist/graphdb-free-${GDB_VERSION}-dist.zip && \
		mkdir -p /opt && mv graphdb-free-${GDB_VERSION} /opt/graphdb && \
		rm -rf dist

# Volumes for runtime data
VOLUME /opt/graphdb/data
VOLUME /opt/graphdb/log
VOLUME /opt/graphdb/conf
VOLUME /opt/graphdb/work

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 7200