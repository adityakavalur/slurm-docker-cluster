#!/bin/bash
set -e

docker exec slurmctld bash -c "/usr/bin/sacctmgr --immediate add cluster name=mycluster" && \
docker-compose restart slurmdbd slurmctld
