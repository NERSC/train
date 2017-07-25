#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
##SBATCH --reservation=csgftrain  # our reservation today

# we'll run multiple copies of our hack-a-kernel from ex3:
ex=../ex3-building_apps/hack-a-kernel-v0.ex

# for the first experiemnt, we'll run 16 copies of hack-a-kernel
# with no special affinity settings:
echo "#### first experiment: no affinity settings ####"
srun --label -n 16 ./check-placement.sh $ex

# the '-c' option for srun reserves a number of CPUs (ie, hyperthreads) 
# for each task. But this only affects the number of cpus reserved, not
# the actual placement of tasks. 
# KNL has 4 cpus per core, so we'll reserve 4 cpus for each copy:
echo ""
echo ""
echo "#### second experiment: use -c to reserve cpus ####"
srun --label -n 16 -c 4 ./check-placement.sh $ex

# now we'll use --cpu_bind to prevent tasks from landing on the same core:
echo ""
echo ""
echo "#### third experiment: use --cpu_bind to bind threads to cores ####"
srun --label -n 16 -c 4 --cpu_bind=cores ./check-placement.sh $ex

# finally, we can use -c and --cpu_bind together to, for example, give each
# task its own tile (so tasks do not share L2 caches)
echo ""
echo ""
echo "#### fourth experiment: give each task its own tile ####"
srun --label -n 16 -c 8 --cpu_bind=cores ./check-placement.sh $ex









srun --label -n 1 ./hack-a-kernel-v0.ex

