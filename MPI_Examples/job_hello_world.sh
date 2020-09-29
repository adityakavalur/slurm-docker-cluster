#!/bin/bash
#SBATCH --job-name=hello_world
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

srun --mpi=pmi2 ./hello_world
