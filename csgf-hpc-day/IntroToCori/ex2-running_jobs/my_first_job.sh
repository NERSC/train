#!/bin/bash -l
#SBATCH -N 2                     # Use 2 nodes
#SBATCH -t 5                     # Set 5 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=csgftrain  # our reservation today

# for this exercise we'll run 10 tasks, distributed 
# across all of the nodes in our job:
ntasks=10
nnodes=$SLURM_NNODES

rundir=$SCRATCH/csgf-hpc-day/IntroToCori/ex2-running_jobs
mkdir -p $rundir
cd $rundir

if [[ `pwd` != "$rundir" ]]; then
  echo "Something is wrong!"
fi

echo "running a simple command in `pwd`"
srun --label -N $nnodes -n $ntasks bash -c 'printf "%s\n" "hello from `uname -n`"'
