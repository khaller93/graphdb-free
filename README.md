Ontotext doesn't provide docker images for the free version of GraphDB. A dockerfile for the free version can be found on their [github](https://github.com/Ontotext-AD/graphdb-docker) although. The Dockerfile in this repository is slightly different. It makes it possible to preload data at the time at which the container is created as well as to define a fulltext-search index at creation time.

**PS: Should it be a problem that I publish these docker images, please simply contact me.**


# Building

The dockerfile expects the GraphDB binaries to be located in the `dist` directory in the form in which they are downloaded from Ontotext (as a zip file). However, this github repository doesn't provide them and you must download them on your own from the Ontotext website. If you want to download the latest GraphDB version, please go to the [Ontotext GraphDB website](https://www.ontotext.com/products/graphdb/) and fill out the form.

## Building a fresh image

The Dockerfile is simple, it only expects you to pass the version of the GraphDB binaries for which you want to build the image. Download the corresponding binaries, move them into the `dist` directory and build
the image with the following command (replace 8.11.0 with your version):

`docker build --build-arg GDB_VERSION="8.11.0" --build-arg -t khaller/graphdb-free:1.2-graphdb8.11.0 .`

# Running

The image can be run as following. 

`docker run -p 127.0.0.1:7200:7200 --name graphdb-instance-name -t khaller/graphdb-free:tag`

You can pass arguments to the GraphDB server such as the heap size or `-s` for making it run in server mode.

`docker run -p 127.0.0.1:7200:7200 --name graphdb-instance-name -t khaller/graphdb-free:tag -s --GDB_HEAP_SIZE=12G`

# Preloading Data

In order to preload data, the directory with the data files (in a supported format) have to be mounted to `/data/toLoad`. Moreover, the configuration of
the repository, into which the data shall be loaded, must be specified by passing it in form of environment variables. `CONF_REPOSITORY_ID` as well as `CONF_REPOSITORY_LABEL` are required, while other settings are optional. [GraphDB repository documentation](http://graphdb.ontotext.com/documentation/standard/configuring-a-repository.html) explains possible settings. Here is a list of them, as they are expected by our image.

| Envorinment variable name |
|---|
| CONF_REPOSITORY_ID |
| CONF_REPOSITORY_LABEL |
| CONF_REPOSITORY_SAIL_TYPE |
| CONF_SAIL_TYPE |
| CONF_BASE_URL |
| CONF_DEFAULT_NS |
| CONF_ENTITY_INDEX_SIZE |
| CONF_ENTITY_ID_SIZE |
| CONF_IMPORTS |
| CONF_REPOSITORY_TYPE |
| CONF_RULESET |
| CONF_STORAGE_FOLDER |
| CONF_ENABLE_CONTEXT_INDEX |
| CONF_ENABLE_PREDICATE_LIST |
| CONF_IN_MEMORY_LITERAL_PROPERTIES |
| CONF_ENABLE_LITERAL_INDEX |
| CONF_CHECK_FOR_INCONSISTENCIES |
| CONF_DISABLE_SAMEAS |
| CONF_QUERY_TIMEOUT |
| CONF_QUERY_LIMIT_RESULTS |
| CONF_READ_ONLY |
| CONF_THROW_QUERY_EVALUATION_EXCEPTION_ON_TIMEOUT |

See below an example of running an image with preloading data contained in `./data` into the repository with the id `repository-id`.

` docker run --name graphdb-instance-name -p 127.0.0.1:7200:7200 \
		-e CONF_REPOSITORY_ID="repository-id" \
		-e CONF_REPOSITORY_LABEL="repository label" \
		-v ./data":/data/toLoad \
		-v ./.graphdb:/opt/graphdb/data \
		-d khaller/graphdb-free:1.2-graphdb8.11.0 \
		--GDB_HEAP_SIZE="2G"
`

## Create fulltext-search index

In order to create a fulltext search index, `CONF_ENABLE_FTS` must be set to `true` and similar to the repository configuration, the required setting `CONF_FTS_INDEX_NAME` must be specified, while other settings can be set optionally. [GraphDB fulltext index documentation](http://graphdb.ontotext.com/documentation/free/full-text-search.html)

| Envorinment variable name |
|---|
| CONF_FTS_INDEX_NAME |
| CONF_FTS_EXCLUDE |
| CONF_FTS_EXCLUDE_ENTITIES |
| CONF_FTS_EXCLUDE_PREDICATES |
| CONF_FTS_INCLUDE |
| CONF_FTS_INCLUDE_ENTITIES |
| CONF_FTS_INCLUDE_PREDICATES |
| CONF_FTS_INDEX |
| CONF_FTS_LANGUAGES |
| CONF_FTS_MOLECULE_SIZE |
| CONF_FTS_USE_RDF_RANK |

` docker run --name graphdb-instance-name -p 127.0.0.1:7200:7200 \
		-e CONF_REPOSITORY_ID="repository-id" \
		-e CONF_REPOSITORY_LABEL="repository label" \
		-e CONF_ENABLE_FTS="true" \
		-e CONF_FTS_INDEX_NAME="esm" \
		-v ./data":/data/toLoad \
		-v ./.graphdb:/opt/graphdb/data \
		-d khaller/graphdb-free:1.2-graphdb8.11.0 \
		--GDB_HEAP_SIZE="2G"
`

# Where to store your data?

***Important note from the official Ontotext dockerhub repository:*** There are several ways to store data used by applications that run in Docker containers. We encourage users of the GraphDB images to familiarize themselves with the options available, including:

* Let Docker manage the storage of your database data by writing the database files to disk on the host system using its own internal volume management. This is the default and is easy and fairly transparent to the user. The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.
    
* Create a data directory on the host system (outside the container) and mount this to a directory visible from inside the container. This places the database files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area. We will simply show the basic procedure here for the latter option above:

1. Create a data directory on a suitable volume on your host system, e.g. /my/own/graphdb-home.
2. Start your graphdb container like this: `docker run -p 127.0.0.1:7200:7200 -v /my/own/graphdb-home:/opt/graphdb/data --name graphdb-instance-name -t khaller/graphdb-free:tag`

The -v /my/own/graphdb-home:/opt/graphdb/data part of the command mounts the /my/own/graphdb-home directory from the underlying host system as /opt/graphdb/data inside the container, where GraphDB by default will write its data files, logs and working files.

Note that users on host systems with SELinux enabled may see issues with this. The current workaround is to assign the relevant SELinux policy type to the new data directory so that the container will be allowed to access it:

`chcon -Rt svirt_sandbox_file_t /my/own/graphdb-home`
