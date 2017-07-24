#!/bin/bash

#### Which partition? 
#SBATCH -p regular

#### name of the training reservation
#SBATCH --reservation="CUG2B"

#### How many nodes?
#SBATCH -N 1

#### How long to run the job?
#SBATCH -t 00:5:00

#### Our reservation is for Haswell nodes
#SBATCH -C haswell

#### Name the job
#SBATCH -J "job_stage_in"

#### Set the output file name
#SBATCH -o "job_stage_in.log"


#### Request a 200GB scratch allocation, striped over BB nodes 
#DW jobdw capacity=200GB access_mode=striped type=scratch pool=wlm_pool

#### Stage in a directory. Remember to change this directory to your training account scratch directory! 
#DW stage_in source=/global/cscratch1/sd/djbard/CUG2017/data  destination=$DW_JOB_STRIPED/data  type=directory



#### print the mount point of your BB allocation on the compute nodes
echo "*** The path to my BB allocation is:"
echo $DW_JOB_STRIPED

#### Check what's been staged in to your allocation
echo "*** what's on my scratch allocation?"

echo "ls -lrtha  $DW_JOB_STRIPED/ "
ls -lrtha  $DW_JOB_STRIPED/ 

echo "ls -lrtha  $DW_JOB_STRIPED/data/  "
ls -lrtha  $DW_JOB_STRIPED/data/




