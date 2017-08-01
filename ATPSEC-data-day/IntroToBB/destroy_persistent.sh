#!/bin/bash

#### Which partition? 
#SBATCH -p regular

#### name of the training reservation
#SBATCH --reservation="atpesctrain"

#### How many nodes?
#SBATCH -N 1

#### How long to run the job?
#SBATCH -t 00:1:00

#### Our reservation is for haswell nodes
#SBATCH -C haswell

#### Name the job
#SBATCH -J "job_destroy_persistent"

#### Set the output file name
#SBATCH -o "job_destroy_persistent.log"


#### Destroy the persistent reservation. All data on the reservation will be lost. Remember to use the correct reservation name! 
#BB destroy_persistent name=my_persistent_reservation



