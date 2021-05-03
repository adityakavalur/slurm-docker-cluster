#!/bin/bash
#SBATCH --job-name=hello_world
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --time=00:05:00

export SCRATCH=/data/scratch/$USER
module load xalt2

srun --mpi=pmi2 ./hello_world

python3 /data/relocate_xaltjson.py
