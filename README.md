# Dockerfile for GraphDB (free version) 

Ontotext doesn't provide Docker images for the free version of GraphDB. Although, a Dockerfile for the free version can be found on their [Github](https://github.com/Ontotext-AD/graphdb-docker). The Dockerfile in this repository is slightly different. A small program is executed before the start of the GraphDB instance that checks whether repositories shall be initialized. Moreover, another small program scans for SPARQL queries in the initialization folder and sends them to the GraphDB instance at the first startup. This could be useful for automatically creating a FTS index. Sections below are elaborating on these features.

**PS: Should it be a problem that I publish these docker images, please simply contact me.**

Already built images for use can be found [here](https://hub.docker.com/repository/docker/khaller/graphdb-free).

## Building

The Dockerfile expects the GraphDB binaries to be located in the `dist` directory in the form in which they are downloaded from Ontotext (as a zip file). However, this github repository doesn't provide them and you must download them on your own from the Ontotext website. If you want to download the latest GraphDB version, please go to the [Ontotext GraphDB website](https://www.ontotext.com/products/graphdb/) and fill out the form.

## Building a fresh image

The Dockerfile is simple, it only expects you to pass the version of the GraphDB binaries for which you want to build the image. Download the corresponding binaries, move them into the `dist` directory and build the image with the following command (replace 8.11.0 with your version):

`docker build --build-arg GDB_VERSION="9.3.3" --build-arg -t khaller/graphdb-free:1.3.3-graphdb9.3.3 .`

## Running

The image can be run as following. 

`docker run -p 127.0.0.1:7200:7200 --name graphdb-instance-name -t khaller/graphdb-free:1.3.3-graphdb9.3.3`

You can pass arguments to the GraphDB server such as the heap size or `-s` for making it run in server mode.

`docker run -p 127.0.0.1:7200:7200 --name graphdb-instance-name -t khaller/graphdb-free:1.3.3-graphdb9.3.3 -s --GDB_HEAP_SIZE=12G`

## Repository Initialization

Multiple repositories can be managed on the same GraphDB instances, and built images of version `>=1.3.0` include a small program (written in GO) that scans the `/repository.init/` directory for configurations of repositories. If you want a repository to be initialized at the first start, you have to define a subfolder (name is not relevant) in `/repository.init/`, and add a `config.ttl` to it. Ontotext wrote an [article](http://graphdb.ontotext.com/documentation/standard/configuring-a-repository.html) about how such a configuration file has to look like. A minimalistic example is shown below.

```
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
@prefix rep: <http://www.openrdf.org/config/repository#>.
@prefix sr: <http://www.openrdf.org/config/repository/sail#>.
@prefix sail: <http://www.openrdf.org/config/sail#>.
@prefix owlim: <http://www.ontotext.com/trree/owlim#>.

[] a rep:Repository ;
    rep:repositoryID "dbpedia" ;
    rdfs:label "DBPedia" ;
    rep:repositoryImpl [
        rep:repositoryType "graphdb:FreeSailRepository";
        sr:sailImpl [
            sail:sailType "graphdb:FreeSail" ;
            owlim:entity-index-size "100000000" ;
        ]

    ].
```

Optionally, data that must be preloaded can be added to the `toLoad` directory of the corresponding repository folder in a format that is supported by the [PreLoad Tool](http://graphdb.ontotext.com/documentation/standard/loading-data-using-preload.html) of the given GraphDB version. The [PreLoad Tool](http://graphdb.ontotext.com/documentation/standard/loading-data-using-preload.html) can handle GZip compressed files.

The organization of the `/repository.init/` could look like this, and the small program would initialize both of those repositories and preload the data.

```
dbpedia/
├── config.ttl
└── toLoad
wikidata/
├── config.ttl
└── toLoad
```

After an successful initialization an `init.lock` file is added to the corresponding repository folder. If you want to re-initialize a repository, you can delete this lock and run a new container.

## SPARQL Prequerying

After version `>=1.3.3` our Docker image also include a small Go program that scans recursively for all files with the file ending `.sparql` in folders of the directory `/repository.init/`. The program is going to send those queries to the running GraphDB instance, if they have not been sent to it before. The programs knows whether it has been sent before by checking the `sparql.lock` file in the corresponding folder of the repository. This lock file contains a list of all queries that have been successfully sent to the GraphDB instance. 

### Full-Text-Search Use Case

You want to automatically create a FTS index after the repository has been created and data has been loaded into it. A FTS is created in GraphDB by issuing an update query with your configuration. Ontotext wrote in their [article](http://graphdb.ontotext.com/documentation/free/full-text-search.html) about all the options that you can configure.

You would create the update query for the FTS index and place it in the folder of the corresponding repository. Considering the example above for the repository initialization, it can look like this.

```
dbpedia/
├── config.ttl
├── fts-m2-index.sparql
└── toLoad
```

## Where to store your data?

***Important note from the official Ontotext dockerhub repository:*** There are several ways to store data used by applications that run in Docker containers. We encourage users of the GraphDB images to familiarize themselves with the options available, including:

* Let Docker manage the storage of your database data by writing the database files to disk on the host system using its own internal volume management. This is the default and is easy and fairly transparent to the user. The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.
    
* Create a data directory on the host system (outside the container) and mount this to a directory visible from inside the container. This places the database files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area. We will simply show the basic procedure here for the latter option above:

1. Create a data directory on a suitable volume on your host system, e.g. /my/own/graphdb-home.
2. Start your graphdb container like this: `docker run -p 127.0.0.1:7200:7200 -v /my/own/graphdb-home:/opt/graphdb/data --name graphdb-instance-name -t khaller/graphdb-free:tag`

The -v /my/own/graphdb-home:/opt/graphdb/data part of the command mounts the /my/own/graphdb-home directory from the underlying host system as /opt/graphdb/data inside the container, where GraphDB by default will write its data files, logs and working files.

Note that users on host systems with SELinux enabled may see issues with this. The current workaround is to assign the relevant SELinux policy type to the new data directory so that the container will be allowed to access it:

`chcon -Rt svirt_sandbox_file_t /my/own/graphdb-home`

## Administrative Details

### Feedback & Contributions

Feel free to submit bugs and features with using the ticket manager of Github.

### Contact

* Kevin Haller - [kevin.haller@tuwien.ac.at](mailto:kevin.haller@tuwien.ac.at)
