#!/bin/ksh

#### Which partition? 
#SBATCH -p regular

#### name of the training reservation
#SBATCH --reservation="atpesctrain"

#### How many nodes? Let's try driving IOR from 4 nodes. The BB allocation will be mounted on all of them.  
#SBATCH -N 4

#### How long to run the job? IOR is fast, so we only need 5 minutes. 
#SBATCH -t 00:5:00

#### Our reservation is for Haswell nodes
#SBATCH -C haswell

#### Name the job
#SBATCH -J "job_run_IOR"

#### Set the output file name
#SBATCH -o "job_run_IOR.log"

#### Request a 200GB scratch allocation. Note that you will need to request enough space on the BB to accomodate your IOR test - this will be (# nodes * # ranks per node * block size)
#DW jobdw capacity=200GB access_mode=striped type=scratch







#### Set the current directory 
DIR=$PWD

#### Tell IOR that you'll be running on the Burst Buffer allocation. Change this if you want to write to another location (for example, your home or scratch directory). 
TESTDIR=$DW_JOB_STRIPED

#### Define the transfer size for IOR
TRANSFER_SIZE=1MiB

#### Define the block size for IOR
BLOCK_SIZE=100MiB

#### How many MPI ranks do we use per node? 
RANKS_PER_NODE=32

#### How many nodes did we ask for?
NODES=$SLURM_JOB_NUM_NODES

#### Define how many total MPI ranks we will run. This is the nubmer of nodes times the number of ranks per node we spcified earlier. 
RANKS=$(( $NODES*$RANKS_PER_NODE ))

#### IOR options. 
OPTIONS="-g -t $TRANSFER_SIZE -b $BLOCK_SIZE -o ${TESTDIR}/IOR_file -v"





#### Run IOR to test for all MPI ranks writing to a single shared file. 
#### First define the name of the output file. 
BASE=$DIR/mssf_${TRANSFER_SIZE}_${BLOCK_SIZE}_${NODES}nodes_${RANKS}files_wlmpool${DWN}_${SLURM_JOBID}
print ${BASE}
print ${RANKS}
print "   ", ${OPTIONS}
#### Now run IOR. 
time srun -n ${RANKS} --ntasks-per-node=${RANKS_PER_NODE} ./IOR -a MPIIO ${OPTIONS} < /dev/null >> ${BASE}.IOR


#### Run IOR to test for all MPI ranks writing to a single file per process
#### First define the name of the output file
BASE=$DIR/pfpp_${TRANSFER_SIZE}_${BLOCK_SIZE}_${NODES}nodes_${RANKS}files_wlmpool${DWN}_${SLURM_JOBID}
print ${BASE}
#### Now run IOR
time srun -n ${RANKS} --ntasks-per-node=${RANKS_PER_NODE} ./IOR -a POSIX -F -e ${OPTIONS} < /dev/null >> ${BASE}.IOR
