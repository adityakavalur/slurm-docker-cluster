#!/bin/bash
set -e

#Check if user passes who should the directory inside the image
if [ $# -eq 0 ]
  then
  user="root"
else
  user="$1"
fi
 
#Copy the folder MPI_Examples into the docker container for slurmctld into /data which is visible to compute nodes
docker cp MPI_Examples slurmctld:/data

#Within the container set permissions for the folder. This sets to root by default if no user is specified
docker exec slurmctld bash -c "/usr/bin/chown -R $user:$user /data/MPI_Examples"