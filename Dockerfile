FROM openjdk:8-jre

ARG DFILE_VERSION="1.2"
ARG GDB_VERSION

LABEL maintainer="Kevin Haller <keivn.haller@outofbits.com>"
LABEL version="${DFILE_VERSION}-graphdb${GDB_VERSION}"
LABEL description="Fresh new instance of GraphDB ${GDB_VERSION} (free version)."

# Install GraphDB
COPY dist/graphdb-free-${GDB_VERSION}-dist.zip dist/
RUN unzip -q ./dist/graphdb-free-${GDB_VERSION}-dist.zip && \
		mkdir -p /opt/graphdb && \
		mv graphdb-free-${GDB_VERSION}/* /opt/graphdb/
RUN rm -rf dist

# Install start-up scripts
COPY "scripts/load-initial-data.sh" load-initial-data.sh
COPY "scripts/gen-graphdb-config.sh" gen-graphdb-config.sh
COPY "scripts/init-fulltext-index.sh" init-fulltext-index.sh
COPY "scripts/gen-graphdb-fts-config.sh" gen-graphdb-fts-config.sh
COPY "docker-entrypoint.sh" docker-entrypoint.sh


ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["--GDB_HEAP_SIZE=4G"]

EXPOSE 7200