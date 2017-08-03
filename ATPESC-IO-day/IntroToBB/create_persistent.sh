#!/bin/bash

#### Which partition? 
#SBATCH -p regular

#### name of the training reservation
#SBATCH --reservation="atpesctrain"

#### How many nodes?
#SBATCH -N 1

#### How long to run the job? This doesn't need to be long as we're not actually executing anything on the compute node. 
#SBATCH -t 00:1:00

#### Our reservation is for hasawell nodes
#SBATCH -C haswell

#### Name the job
#SBATCH -J "job_create_persistent"

#### Set the output file name
#SBATCH -o "job_create_persistent.log"


#### Create a persistent reservation (PR). Choose what size and name you want to give it. Note that you MUST change this name! Every PR name needs to be unique - if there already exists a PR of this name the job will fail.  
#BB create_persistent name=my_persistent_reservation capacity=300GB access_mode=striped type=scratch 
               




