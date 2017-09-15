#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 5                     # Set 5 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=tapia  # our reservation today

export OMP_NUM_THREADS=5
srun --label -n 1 ./hello-omp.ex
