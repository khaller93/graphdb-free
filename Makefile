DockerfileVersion=1.1
LATEST=8.10.1

latest:
	docker build --build-arg GDB_VERSION=${LATEST} -t khaller/graphdb-free:${DockerfileVersion}-graphdb${LATEST} -t khaller/graphdb-free --no-cache .

8.10.1:
	docker build --build-arg GDB_VERSION="8.10.1" -t khaller/graphdb-free:${DockerfileVersion}-graphdb8.10.1 .

8.10.0:
	docker build --build-arg GDB_VERSION="8.10.0" -t khaller/graphdb-free:${DockerfileVersion}-graphdb8.10.0 .

8.9.0:
	docker build --build-arg GDB_VERSION="8.9.0" -t khaller/graphdb-free:${DockerfileVersion}-graphdb8.9.0 .

up-latest:
	docker push khaller/graphdb-free

up-8.10.0:
	docker push khaller/graphdb-free:${DockerfileVersion}-graphdb8.10.0

up-8.9.0:
	docker push khaller/graphdb-free:${DockerfileVersion}-graphdb8.9.0