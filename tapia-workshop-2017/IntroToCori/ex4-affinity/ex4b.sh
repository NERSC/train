#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 15                    # Set 15 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=csgftrain  # our reservation today

# we'll run multiple copies of our hack-a-kernel from ex3:
ex=../ex3-building_apps/hack-a-kernel-v0.ex

# hack-a-kernel uses about 6GB of memory per instance. Cori KNL nodes have
# 96 GB of memory - some of which is used by the OS - so we'll run 12 copies:

# for the first experiment, we'll use no special affinity settings:
echo "#### first experiment: no affinity settings ####"
t0=$(date +%s)
srun --label -n 12 ./check-placement.sh $ex | sort -sn 
t1=$(date +%s)
echo "experiment 1 completed in $((t1-t0)) seconds"

# the '-c' option for srun reserves a number of CPUs (ie, hyperthreads) 
# for each task. But this only affects the number of cpus reserved, not
# the actual placement of tasks. 
# KNL has 4 cpus per core, so we'll reserve 4 cpus for each copy:
echo ""
echo ""
echo "#### second experiment: use -c to reserve cpus ####"
t0=$(date +%s)
srun --label -n 12 -c 4 ./check-placement.sh $ex | sort -sn 
t1=$(date +%s)
echo "experiment 2 completed in $((t1-t0)) seconds"

# now we'll use --cpu_bind to prevent tasks from landing on the same core:
echo ""
echo ""
echo "#### third experiment: use --cpu_bind to bind threads to cores ####"
t0=$(date +%s)
srun --label -n 12 -c 4 --cpu_bind=cores ./check-placement.sh $ex | sort -sn 
t1=$(date +%s)
echo "experiment 3 completed in $((t1-t0)) seconds"

# finally, we can use -c and --cpu_bind together to, for example, give each
# task its own tile (so tasks do not share L2 caches)
echo ""
echo ""
echo "#### fourth experiment: give each task its own tile ####"
t0=$(date +%s)
srun --label -n 12 -c 8 --cpu_bind=cores ./check-placement.sh $ex | sort -sn 
t1=$(date +%s)
echo "experiment 4 completed in $((t1-t0)) seconds"

