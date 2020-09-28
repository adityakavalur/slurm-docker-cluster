#!/bin/bash
set -e

#Data serves as scratch space, which is exposed to the compute nodes as well
#All users need to be able to write here. Long term, fix this upstream
docker exec slurmctld bash -c "/usr/bin/chmod -R 777 /data"

#Create account in slurm
docker exec slurmctld bash -c "/usr/bin/sacctmgr --immediate add account useraccount description="user account" Organization=Slurm-in-Docker"

#Add one user to the above account, only they can submit jobs
#These users need to be present in the image, they are currently being added in dockerfile
docker exec slurmctld bash -c "/usr/bin/sacctmgr --immediate create user user1 account=useraccount adminlevel=None"

