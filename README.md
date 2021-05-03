# Slurm Docker Cluster

This is a multi-container Slurm cluster using docker-compose.  The compose file
creates named volumes for persistent storage of MySQL data files as well as
Slurm state and log directories.

## Containers and Volumes

The compose file will run the following containers:

* mysql
* slurmdbd
* slurmctld
* compute1 (slurmd)
* compute2 (slurmd)

The compose file will create the following named volumes:

* etc_munge         ( -> /etc/munge     )
* etc_slurm         ( -> /etc/slurm     )
* slurm_jobdir      ( -> /data          )
* var_lib_mysql     ( -> /var/lib/mysql )
* var_lib_mysql2    ( -> /var/lib/mysql2 )
* var_log_slurm     ( -> /var/log/slurm )

## Building the Docker Image

Build the image locally:

```console
docker build -t slurm-docker-cluster:20.02.4 .
```

Build a different version of Slurm using Docker build args and the Slurm Git
tag:

```console
docker build --build-arg SLURM_TAG="slurm-19-05-2-1" -t slurm-docker-cluster:19.05.2 .
```

> Note: You will need to update the container image version in
> [docker-compose.yml](docker-compose.yml).



## Starting the Cluster

Run `docker-compose` to instantiate the cluster:

```console
docker-compose up -d
```

## Register the Cluster with SlurmDBD

To register the cluster to the slurmdbd daemon, run the `register_cluster.sh`
script:

```console
./register_cluster.sh
```

> Note: You may have to wait a few seconds for the cluster daemons to become
> ready before registering the cluster.  Otherwise, you may get an error such
> as **sacctmgr: error: Problem talking to the database: Connection refused**.
>
> You can check the status of the cluster by viewing the logs: `docker-compose
> logs -f`

## Adding users to Slurm

To add users to slurm, so that they can submit jobs, update and run the `addusers.sh` script:

```console
./addusers.sh
```
> Note: You must ensure any new user added to the slurm database already exists
> in the docker image. This is currently being done through the Dockerfile.

## Installing environment modules or lmod
To install environment modules, run the script `envmod.sh`. This will install tcl and environment
modules in /data 

To install Lmod run the script `lmod.sh`. This will install lmod in /data and put necessary 
files in /usr/local, /usr/include and /etc/profile.d on the 'login' and compute nodes.
```console
./envmod.sh
```
> Note: There is an example module file in MPI_Examples. The tcl/lua files need to be placed under
/data/modulefiles/<sw name>/<version> 

## Moving source code into the container

To move source code into the cluster, run the `codes_from_source.sh` script. This moves 
the folder in MPI_Examples into the container under /data, which is mounted on the 'login' 
as well as compute nodes. The default setting is to assign ownership of the folder to root, 
however, you can pass an argument to override that
```console
./codes_from_source.sh user1
```  

## Install XALT2
To install xalt2, run the script `xalt2.sh`. This will source and install xalt2 v2.9.8 as well
as create a tcl modulefile for it under /data, that needs to be moved to an appropriate location.
```console
./xalt2.sh
```
Alternatively, you can target a custom xalt repository/branch/version
```console
./xalt2.sh https://github.com/adityakavalur/xalt.git userjsonindex SCRATCH 
```

## Accessing the Cluster

Use `docker exec` to run a bash shell on the controller container:

```console
docker exec -it slurmctld bash
```

From the shell, execute slurm commands, for example:

```console
[root@slurmctld /]# su user1
[user1@slurmctld /]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST 
normal*      up 5-00:00:00      2   idle compute[1-2] 
```

## Submitting Jobs

The `slurm_jobdir` named volume is mounted on each Slurm container as `/data`.
Therefore, in order to see job output files while on the controller, change to
the `/data` directory when on the **slurmctld** container and then submit a job:

```console
[root@slurmctld /]# su user1
[user1@slurmctld /]$ cd /data/MPI_Examples/
[user1@slurmctld MPI_Examples]$ sbatch job_hello_world.sh 
Submitted batch job 2
[user1@slurmctld MPI_Examples]$ cat slurm-2.out 
Hello world from processor compute2, rank 2 out of 4 processors
Hello world from processor compute1, rank 1 out of 4 processors
Hello world from processor compute2, rank 3 out of 4 processors
Hello world from processor compute1, rank 0 out of 4 processors
[user1@slurmctld MPI_Examples]$ sbatch job_hello_world_python.sh 
Submitted batch job 3
[user1@slurmctld MPI_Examples]$ cat slurm-3.out 
Hello, World! I am process 2 of 4 on compute2.
Hello, World! I am process 0 of 4 on compute1.
Hello, World! I am process 3 of 4 on compute2.
Hello, World! I am process 1 of 4 on compute1.
```

## Stopping and Restarting the Cluster

```console
docker-compose stop
docker-compose start
```

## Deleting the Cluster

To remove all containers, volumes and images, run:

```console
docker-compose stop
docker-compose rm -f
docker volume rm slurm-docker-cluster_etc_munge slurm-docker-cluster_etc_slurm slurm-docker-cluster_slurm_jobdir slurm-docker-cluster_var_lib_mysql slurm-docker-cluster_var_lib_mysql2 slurm-docker-cluster_var_log_slurm
docker rmi slurm-docker-cluster:20.02.4 mysql:5.7
```
> Note: In the last step step substitute the tag you used, if not using the default.
