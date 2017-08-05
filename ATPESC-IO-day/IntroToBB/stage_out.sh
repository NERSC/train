#!/bin/bash

#### Which partition? 
#SBATCH -p regular

#### name of the training reservation
#SBATCH --reservation="atpesctrain"

#### How many nodes?
#SBATCH -N 1

#### How long to run the job?
#SBATCH -t 00:01:00

#### Our reservation is for Haswell nodes
#SBATCH -C haswell

#### Name the job
#SBATCH -J "job_stage_out"

#### Set the output file name
#SBATCH -o "job_stage_out.log"

#### Request a 200GB scratch allocation, striped over BB nodes 
#DW jobdw capacity=200GB access_mode=striped type=scratch pool=wlm_pool

#### Stage a file out of the BB onto scratch. 
#DW stage_out destination=/global/cscratch1/sd/djbard/train/csgf-hpc-day/IntroToBB/data/hello.txt source=$DW_JOB_STRIPED/hello.txt type=file



#### print the mount point of your BB allocation on the compute nodes
echo "*** DW path is:"
echo $DW_JOB_STRIPED

#### Write a file on the BB
echo "*** saying hello...."
echo "Hello! I'm on the Burst Buffer!" > $DW_JOB_STRIPED/hello.txt
echo "*** ls -larth $DW_JOB_STRIPED/"
ls -larth $DW_JOB_STRIPED/
echo "*** cat $DW_JOB_STRIPED/hello.txt"
cat $DW_JOB_STRIPED/hello.txt

