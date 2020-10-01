## MPI Examples

The quintessential hello_world example using slurm on the docker cluster.

### hello_world

The code is from Wes Kendall (see the header in hello_world.c) The format is from richarskg (https://github.com/richardskg)

To copy and set appropriate permissions:

From the parent directory run:
```console
./codes_from_source.sh
```

To run the example on the cluster:
Enter the slurmctld container
```console
docker exec -it slurmctld bash
```
Change into a user who can run jobs on the cluster:
```console
su user1
```
> Note: If you use OpenMPI instead of the provided MPICH, it will throw up an error
> when you try to run an MPI job as root.

Go to the directory, compile and submit job
```console
cd /data/MPI_Examples
make
sbatch hello_world.sh
```

Example lmod module file can be found in 0.lua. Copy the module file to the modulefiles folder. 
```console  
mkdir /data/modulefiles/hello-world
mv 0.lua /data/modulefiles/hello-world 
```

> Note: Change the default job submission file to include the module load command and replace the executable call.
 