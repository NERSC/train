#!/bin/bash

#### Which partition?
#SBATCH -p debug

#### name of the training reservation
###SBATCH --reservation="csgftrain"

#### How many nodes?
#SBATCH -N 1

#### How long to run the job?
#SBATCH -t 00:5:00

#### Our reservation is for KNL nodes
#SBATCH -C knl

#### Name the job
#SBATCH -J "job_dwstat"

#### Set the output file name
#SBATCH -o "job_dwstat.log"


#### Request a 200GB scratch allocation, striped over BB nodes 
#DW jobdw capacity=200GB access_mode=striped type=scratch pool=wlm_pool




#### print the mount point of your BB allocation on the compute nodes
echo "*** DW path is:"
echo $DW_JOB_STRIPED


#### find out which DW nodes your allocation is striped over
echo "*** what nodes are my allocation striped over?"
module load dws

sessID=$(dwstat sessions | grep $SLURM_JOBID | awk '{print $1}')
echo "session ID is: "${sessID}
instID=$(dwstat instances | grep $sessID | awk '{print $1}')
echo "instance ID is: "${instID}
echo "fragments list:"
echo "frag state instID capacity node"
dwstat fragments | grep ${instID}
