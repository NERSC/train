#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 5                     # Set 5 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes

# In this exercise we'll start a small enough number of simultaneous tasks that
# each **should** get its own core, and use `ps` in the background to show that
# it does not necessarily do so.
# 
# In each of the 4 job steps below, we'll call `sleep 20` via the 
# `check_placement.sh` script in this directory.
#
# Take a look also at the `check_placement,sh` script. There's a lot of `bash`
# and `awk` there but what it does is start a command in the background, wait
# a few seconds, then capture the output of `ps` and use it to find which cores
# are being used.
#
# Once the job completes, take a look at the `slurm-<job-id>.out` file. In each
# experiment, how were the tasks distributed over the cores? Did each task get 
# it's own?

ex="sleep 20"

# for the first experiment, we'll use no special affinity settings:
echo "#### first experiment: no affinity settings ####"
srun --label -n 30 ./check-placement.sh $ex | sort -sn 

# the '-c' option for srun reserves a number of CPUs (ie, hyperthreads) 
# for each task. But this only affects the number of cpus reserved, not
# the actual placement of tasks. 
# KNL has 4 cpus per core, so we'll reserve 4 cpus for each copy:
echo ""
echo ""
echo "#### second experiment: use -c to reserve cpus ####"
srun --label -n 30 -c 4 ./check-placement.sh $ex | sort -sn 

# now we'll use --cpu_bind to prevent tasks from landing on the same core:
echo ""
echo ""
echo "#### third experiment: use --cpu_bind to bind threads to cores ####"
srun --label -n 30 -c 4 --cpu_bind=cores ./check-placement.sh $ex | sort -sn 

# finally, we can use -c and --cpu_bind together to, for example, give each
# task its own tile (so tasks do not share L2 caches)
echo ""
echo ""
echo "#### fourth experiment: give each task its own tile ####"
srun --label -n 30 -c 8 --cpu_bind=cores ./check-placement.sh $ex | sort -sn 

