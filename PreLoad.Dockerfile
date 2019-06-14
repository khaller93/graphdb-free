FROM khaller/graphdb-free:1.0-gdb8.9.0

ARG CONF_FILE="toLoad/config.ttl"
ARG DATA_DIR="toLoad/data"

COPY load_initial_data.sh load_initial_data.sh
COPY ${CONF_FILE} ${CONF_FILE}
COPY ${DATA_DIR} ${DATA_DIR}

RUN sh ./load_initial_data.sh ${CONF_FILE} ${DATA_DIR}

RUN rm -f ${CONF_FILE}
RUN rm -rf ${DATA_DIR}

