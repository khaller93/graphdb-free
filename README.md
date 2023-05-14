# Dockerfile for GraphDB (free version) 

Ontotext doesn't provide Docker images for the free version of GraphDB. Although, a Dockerfile for the free version can be found on their [Github](https://github.com/Ontotext-AD/graphdb-docker). The Dockerfile in this repository is slightly different. A small program is executed before the start of the GraphDB instance that checks whether repositories shall be initialized. Moreover, another small program scans for SPARQL queries in the initialization folder and sends them to the GraphDB instance at the first startup. This could be useful for automatically creating a FTS index. Sections below are elaborating on these features.

Already built images for use can be found [here](https://hub.docker.com/repository/docker/khaller/graphdb-free).

**PS: Should it be a problem that I publish these docker images, please simply [contact me](#contact).**

An example of how to use this container image can be seen in the `docker-compose.yml` file of our [Pokémon Playground](https://github.com/pokemon-kg/ontotext-graphdb-playground).

## Building

The Dockerfile expects the GraphDB binaries to be located in the `dist` directory in the form in which they are downloaded from Ontotext (as a zip file). However, this github repository doesn't provide them and you must download them on your own from the Ontotext website. If you want to download the latest GraphDB version, please go to the [Ontotext GraphDB website](https://www.ontotext.com/products/graphdb/) and fill out the form.

## Building a fresh image

The Dockerfile is simple, it only expects you to pass the version of the GraphDB binaries for which you want to build the image. Download the corresponding binaries, move them into the `dist` directory and build the image with the following command (replace 10.2.1 with your version):

```bash
docker build --build-arg GDB_VERSION="10.2.1" -t khaller/graphdb-free:10.2.1 .
```

## Running

The image can be run as following. 

```bash
docker run -p 127.0.0.1:7200:7200 --name graphdb-instance-name -t khaller/graphdb-free:10.2.1
```

You can pass arguments to the GraphDB server such as the heap size or `-s` for making it run in server mode.

```bash
docker run -p 127.0.0.1:7200:7200 --name graphdb-instance-name -t khaller/graphdb-free:10.2.1 -s --GDB_HEAP_SIZE=12G
```

## Rootless Run

The container will by default start with the `root` user, but you might want to drop the execution to a less privileged user. You can choose the user (UID number or name) by setting the `GDB_USER` environment variable. With the command below, the GraphDB instance is run with the `nobody` user.

```bash
docker run -p 7200:7200 --name rootless-graphdb -e GDB_USER=nobody -t khaller/graphdb-free:10.2.1
```

The first regular user on your Linux host system has usually the uid of `1000`. You can get the uid of your host user with `id -u`. If you want GraphDB to run on the same user, then you have to set `GDB_USER` to the proper uid. The container doesn't know the created users on your host system, so you can't specify the name of your host user.

```bash
docker run -p 7200:7200 --name rootless-graphdb -e GDB_USER=1000 -t khaller/graphdb-free:10.2.1
```

## Repository Initialization

Multiple repositories can be managed on the same GraphDB instances, and built images of version `>=1.3.0` include a small program (written in GO) that scans the `/repository.init/` directory for configurations of repositories. If you want a repository to be initialized at the first start, you have to define a subfolder (name is not relevant) in `/repository.init/`, and add a `config.ttl` to it. Ontotext wrote an [article](http://graphdb.ontotext.com/documentation/standard/configuring-a-repository.html) about how such a configuration file has to look like. A minimalistic example is shown below.

**<span style="color:#f03c15">Hint:</span>** *With GraphDB >=10, the repository type `graphdb:FreeSailRepository` was replaced by `graphdb:SailRepository`, and the sail type `graphdb:FreeSail` was replaced by `graphdb:SailRepository`.*

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
        rep:repositoryType "graphdb:SailRepository";
        sr:sailImpl [
            sail:sailType "graphdb:Sail" ;
            owlim:entity-index-size "100000000" ;
        ]

    ].
```

Optionally, data that must be preloaded can be added to the `toLoad` directory of the corresponding repository folder in a format that is supported by the [Importrdf/PreLoad Tool](https://graphdb.ontotext.com/documentation/10.0/loading-data-using-importrdf.html) of the given GraphDB version. The [Importrdf/PreLoad Tool](https://graphdb.ontotext.com/documentation/10.0/loading-data-using-importrdf.html) can handle GZip compressed files.

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

You want to automatically create a FTS index after the repository has been created and data has been loaded into it. A FTS is created in GraphDB by issuing an update query with your configuration. Ontotext wrote in their [article](https://graphdb.ontotext.com/documentation/10.0/general-full-text-search-with-connectors.html) about all the options that you can configure.

You would create the update query for the FTS index and place it in the folder of the corresponding repository. Considering the example above for the repository initialization, it can look like this.

**<span style="color:#f03c15">Hint:</span>** *The syntax for configuring a FTS index has changed with GraphDB >=9.9.*

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
2. Start your graphdb container like this: `docker run -p 127.0.0.1:7200:7200 -v /my/own/graphdb-home:/opt/graphdb/data --name graphdb-instance-name -t khaller/graphdb-free`

The `-v /my/own/graphdb-home:/opt/graphdb/data` part of the command mounts the `/my/own/graphdb-home` directory from the underlying host system as `/opt/graphdb/data` inside the container, where GraphDB by default will write its data files.

Note that users on host systems with SELinux enabled may see issues with this. The current workaround is to assign the relevant SELinux policy type to the new data directory so that the container will be allowed to access it:

`chcon -Rt svirt_sandbox_file_t /my/own/graphdb-home`

## Volumes

* `/opt/graphdb/data` - Database Files
* `/opt/graphdb/work` - Workbench Files (Users, Authorization Details, etc.)
* `/opt/graphdb/conf` - Configuration Files
* `/opt/graphdb/log` - Logging Files

# Hardware Requirements

The stated minimal requirements for running a GraphDB instance are 2GB of RAM and 2GB of disk space unless the loaded RDF dataset has less than 50 millionen triples. It is probably recommended to have at least 4G of free RAM. A table of recommendations is shown below.

* **#Triples** are the planned number of explicit statements.
* **RAM** is the recommended free RAM required for the loaded dataset with ***#Triples***.
* **Disk Space** is the recommended free storage on disk requried to store the loaded dataset with ***#Triples***.

| **#Triples** | **RAM** | **Disk Space** |
| ------------ | ------- | -------------- |
| 100M         | 4GB     | 12GB           |
| 200M         | 8GB     | 24GB           |
| 500M         | 20GB    | 60GB           |
| 1B           | 34GB    | 120GB          |
| 2B           | 38GB    | 240GB          |
| 5B           | 49GB    | 600GB          |
| 10B          | 68GB    | 1200GB         |
| 20B          | 105GB   | 2400GB         |

# Administration

### Feedback & Contributions

Feel free to submit bugs and features on our [Github repository](https://github.com/khaller93/graphdb-free).

### Contact

* Kevin Haller - [contact@kevinhaller.dev](mailto:contact@kevinhaller.dev)

