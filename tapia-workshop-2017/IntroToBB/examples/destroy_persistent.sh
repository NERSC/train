#!/bin/bash

#### Which partition? 
#SBATCH -p special

#### name of the training reservation
#SBATCH --reservation="tapia"

#### How many nodes?
#SBATCH -N 1

#### How long to run the job?
#SBATCH -t 00:1:00

#### Our reservation is for KNL nodes
#SBATCH -C knl

#### Name the job
#SBATCH -J "job_destroy_persistent"

#### Set the output file name
#SBATCH -o "job_destroy_persistent.log"


#### Destroy the persistent reservation. All data on the reservation will be lost. Remember to use the correct reservation name! 
#BB destroy_persistent name=my_persistent_reservation



