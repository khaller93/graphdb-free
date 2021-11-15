DFILE_VERSION=1.3.4
CONTAINER_REPO_NAME="docker.io/khaller"

build:
	@[ "${GDB_VERSION}" ] || ( echo "error: variable 'GDB_VERSION' is not set."; exit 1 )
	docker build --pull \
		--build-arg GDB_VERSION="${GDB_VERSION}" \
		--build-arg DFILE_VERSION="${DFILE_VERSION}" \
		-t "${CONTAINER_REPO_NAME}/graphdb-free:${DFILE_VERSION}-graphdb${GDB_VERSION}" \
		-t "${CONTAINER_REPO_NAME}/graphdb-free:${GDB_VERSION}" \
		.

push:
	@[ "${GDB_VERSION}" ] || ( echo "error: variable 'GDB_VERSION' is not set."; exit 1 )
	docker push "${CONTAINER_REPO_NAME}/graphdb-free:${DFILE_VERSION}-graphdb${GDB_VERSION}"
	docker push "${CONTAINER_REPO_NAME}/graphdb-free:${GDB_VERSION}"

as-latest:
	@[ "${GDB_VERSION}" ] || ( echo "error: variable 'GDB_VERSION' is not set."; exit 1 )
	docker tag "${CONTAINER_REPO_NAME}/graphdb-free:${GDB_VERSION}" -t "${CONTAINER_REPO_NAME}/graphdb-free"
	docker push "${CONTAINER_REPO_NAME}/graphdb-free"