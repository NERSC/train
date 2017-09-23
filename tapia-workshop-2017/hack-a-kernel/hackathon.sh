#!/bin/bash
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=tapia      # our reservation today

module load perftools-base perftools-lite

srun -n 1 ./hack-a-kernel.ex
