#!/bin/bash

#### Which partition? 
#SBATCH -p regular

#### name of the training reservation
#SBATCH --reservation="atpesctrain"

#### How many nodes?
#SBATCH -N 1

#### How long to run the job?
#SBATCH -t 00:1:00

#### Our reservation is for Haswell nodes
#SBATCH -C haswell

#### Name the job
#SBATCH -J "job_stage_in"

#### Set the output file name
#SBATCH -o "job_stage_in.log"

#### Request a 200GB scratch allocation, striped over BB nodes 
#DW jobdw capacity=200GB access_mode=striped type=scratch pool=wlm_pool

#### Stage in a directory. Remember to change this directory to your training account scratch directory! You can also stage_in a file by specifying "type=file". 
#DW stage_in source=/global/cscratch1/sd/djbard/train/csgf-hpc-day/IntroToBB/data/  destination=$DW_JOB_STRIPED/data2  type=directory



#### print the mount point of your BB allocation on the compute nodes
echo "*** The path to my BB allocation is:"
echo $DW_JOB_STRIPED

#### Check what's been staged in to your allocation
echo "*** what's on my scratch allocation?"

echo "ls -lrtha  $DW_JOB_STRIPED/ "
ls -lrtha  $DW_JOB_STRIPED/ 

echo "ls -lrtha  $DW_JOB_STRIPED/data/  "
ls -lrtha  $DW_JOB_STRIPED/data/




