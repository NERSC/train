#!/bin/bash
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes

module unload darshan
module load perftools-base perftools-lite

srun -n 1 -c 4 --cpu_bind=cores ./hack-a-kernel.ex
