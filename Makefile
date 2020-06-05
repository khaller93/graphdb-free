DockerfileVersion=1.3.1
LATEST=9.3.0

latest:
	docker build --build-arg GDB_VERSION=${LATEST} --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb${LATEST} -t khaller/graphdb-free .

9.3.0:
	docker build --build-arg GDB_VERSION="9.3.0" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb9.3.0 .

9.2.1:
	docker build --build-arg GDB_VERSION="9.2.1" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb9.2.1 .

9.2.0:
	docker build --build-arg GDB_VERSION="9.2.0" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb9.2.0 .

9.1.1:
	docker build --build-arg GDB_VERSION="9.1.1" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb9.1.1 .

9.1.0:
	docker build --build-arg GDB_VERSION="9.1.0" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb9.1.0 .

9.0.0:
	docker build --build-arg GDB_VERSION="9.0.0" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb9.0.0 .

8.11.1:
	docker build --build-arg GDB_VERSION="8.11.1" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb8.11.1 .

8.11.0:
	docker build --build-arg GDB_VERSION="8.11.0" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb8.11.0 .

8.10.1:
	docker build --build-arg GDB_VERSION="8.10.1" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb8.10.1 .

8.10.0:
	docker build --build-arg GDB_VERSION="8.10.0" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb8.10.0 .

8.9.0:
	docker build --build-arg GDB_VERSION="8.9.0" --build-arg DFILE_VERSION=${DockerfileVersion} -t khaller/graphdb-free:${DockerfileVersion}-graphdb8.9.0 .
