FROM openjdk:8-jdk

ARG GDB_VERSION

LABEL maintainer="Kevin Haller <keivn.haller@outofbits.com>"
LABEL version="1.0-graphdb${GDB_VERSION}"
LABEL description="Fresh new instance of GraphDB ${GDB_VERSION} (free version)."

COPY dist/graphdb-free-${GDB_VERSION}-dist.zip dist/

RUN unzip -q ./dist/graphdb-free-${GDB_VERSION}-dist.zip && \
		mkdir -p /opt/graphdb && \
		mv graphdb-free-${GDB_VERSION}/* /opt/graphdb/

RUN rm -rf dist

ENTRYPOINT ["/opt/graphdb/bin/graphdb"]
CMD ["--GDB_HEAP_SIZE=4G"]

EXPOSE 7200