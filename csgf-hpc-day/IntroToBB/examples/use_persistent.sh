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
#SBATCH -J "job_use_persistent"

#### Set the output file name
#SBATCH -o "job_use_persistent.log"


#### Specify which persistent reservation you will access. Remember to use the correct reservation name!
#DW persistentdw name=my_persistent_reservation


#### Stage in some data to the persistent reservation. Remember to change this to point to your data! 
#DW stage_in source=/global/cscratch1/sd/djbard/CUG2017/data/ destination=$DW_PERSISTENT_STRIPED_my_persistent_reservation/data/ type=directory




#### print the mount point of your BB allocation on the compute nodes
echo "*** The path to my BB allocation is:"
echo $DW_PERSISTENT_STRIPED_my_persistent_reservation

#### Check what's been staged in to your allocation
ls
echo "*** What's on my persistent reservation?:"

echo "*** ls -lrt  $DW_PERSISTENT_STRIPED_my_persistent_reservation "
ls -lrt  $DW_PERSISTENT_STRIPED_my_persistent_reservation


echo "*** ls -lrt  $DW_PERSISTENT_STRIPED_my_persistent_reservation "
ls -lrt  $DW_PERSISTENT_STRIPED_my_persistent_reservation/data

