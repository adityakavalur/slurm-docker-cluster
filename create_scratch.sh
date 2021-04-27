#!/bin/bash

nusers=$(sacctmgr list users | tail -n+3 | awk '{print $1}' | wc -l)
mkdir /data/scratch
if [[ $nusers = "0" ]]; then return 1; fi
iuser=0
while [[ "${iuser}" -lt "${nusers}" ]]
do
   iuser=$(($iuser+1))
   temp_user=$(sacctmgr list users | tail -n+3 | awk '{print $1}' | sed -n "${iuser}p")
   mkdir /data/scratch/${temp_user}
   chown ${temp_user}:${temp_user} /data/scratch/${temp_user}
   echo "export SCRATCH=/data/scratch/${temp_user}/" >> /home/${temp_user}/.bash_profile 
done
