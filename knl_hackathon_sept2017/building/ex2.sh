#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes

# Slurm will start us in the directory we submitted the job
# srun is not strictly necessary here (it's a serial job), but we'll get
# into the habit of using it:

srun --label -n 1 ./hack-a-kernel-v0.ex

# for an MPI job, placement counts, so we would use something more like 
# what we did in ex1:
#srun --label -n 30 -c 4 --cpu_bind=cores ./check-placement.sh $ex | sort -sn 
