Ontotext does not provide docker images for the free version of GraphDB. A dockerfile for the free version can be found on their [github](https://github.com/Ontotext-AD/graphdb-docker) although. The dockerfile in this repository is slightly different and an additional one is provided here for preloading data into a certain repository with a given configuration.

PS: Should it be a problem that I publish these docker images, please simply contact me. 


# Building

The dockerfile expects the GraphDB binaries to be located in the `dist` directory in the form in which they are downloaded from Ontotext (as a zip file). However, this github repository does not provide them and you must download them on your own from the Ontotext website. If you want to download the latest GraphDB version, please go to the [Ontotext GraphDB website](https://www.ontotext.com/products/graphdb/) and fill out the form.

## Building a fresh image

The Dockerfile is simple, it only expects you to pass the version of the GraphDB binaries for which you want to build the image. Download the corresponding binaries, move them into the `dist` directory and build
the image with the following command (replace 8.9.0 with your version):

`docker build --build-arg GDB_VERSION="8.9.0" -t khaller/graphdb-free:1.0-graphdb8.9.0 .`


## Building an image with preloaded data

This Dockerfile expects at the moment to arguments, the path to the configuration file for the repository (named `CONF_FILE`) and the path to the directory containing the data that shall be loaded in the corresponding repository (named `DATA_DIR`). The later argument can also be missing and this will let the repository be empty. Both of the paths must be part of the Docker context, it cannot refer to a random location on your filesystem.

`docker build -f Preload.Dockerfile --build-arg CONF_FILE="/toLoad/config.ttl" --build-arg DATA_DIR="/toLoad/data"-t uname/iname:tag .`

The created image will be based on the latest GraphDB image, which can be changed by editing the `Preload.Dockerfile`.


# Running

The image can be run as following. 

`docker run -p 127.0.0.1:7200:7200 --name graphdb-instance-name -t khaller/graphdb-free:tag`

You can pass arguments to the GraphDB server such as the heap size or `-s` for making it run in server mode without workbench.

`docker run -p 127.0.0.1:7200:7200 --name graphdb-instance-name -t khaller/graphdb-free:tag -s --GDB_HEAP_SIZE=12G`


# Where to store your data?

Important note from the official Ontotext dockerhub repository: There are several ways to store data used by applications that run in Docker containers. We encourage users of the GraphDB images to familiarize themselves with the options available, including:

	Let Docker manage the storage of your database data by writing the database files to disk on the host system using its own internal volume management. This is the default and is easy and fairly transparent to the user. The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.
    
    Create a data directory on the host system (outside the container) and mount this to a directory visible from inside the container. This places the database files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area. We will simply show the basic procedure here for the latter option above:

	1. Create a data directory on a suitable volume on your host system, e.g. /my/own/graphdb-home.
	2. Start your graphdb container like this: `docker run -p 127.0.0.1:7200:7200 -v /my/own/graphdb-home:/opt/graphdb/data --name graphdb-instance-name -t khaller/graphdb-free:tag`

The -v /my/own/graphdb-home:/opt/graphdb/data part of the command mounts the /my/own/graphdb-home directory from the underlying host system as /opt/graphdb/data inside the container, where GraphDB by default will write its data files, logs and working files.

Note that users on host systems with SELinux enabled may see issues with this. The current workaround is to assign the relevant SELinux policy type to the new data directory so that the container will be allowed to access it:

`chcon -Rt svirt_sandbox_file_t /my/own/graphdb-home`