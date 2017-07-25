#!/bin/bash -l
#SBATCH -N 2                     # Use 2 nodes
#SBATCH -t 5                     # Set 5 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=csgftrain  # our reservation today

nnodes=2
ntasks=4

srun --label -N $nnodes -n $ntasks ./hello-mpi.ex
