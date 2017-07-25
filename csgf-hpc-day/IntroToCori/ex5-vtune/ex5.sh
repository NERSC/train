#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --perf=vtune             # use Vtune
#SBATCH --reservation=csgftrain  # our reservation today

module unload darshan
module load vtune

# if we are not in $SCRATCH, abort:
[[ $PWD =~ ^$SCRATCH ]] || { echo "must run in \$SCRATCH" ; exit 2 ; }

# set the Vtune collection options we want:
# A good starting point is the 'hpc-performance' experiment:
vtuneopts="-collect hpc-performance"

# By default Vtune "finalizes" (collates and prepares) its results at the end
# of each run. This procedure is serial and slow - not a good use of compute
# node time in any case, and even worse on KNL as the type of workload is not
# suited to the KNL architecture. So we'll defer finalization and do it on the
# command line later:
vtuneopts+=" -finalization-mode=none"

# VTune doesn't target MPI programs, but if you are analysing an MPI program
# it is best to let Vtune know: (we don't need this today)
#vtuneopts+=" -trace-mpi"

# We'll put the Vtune results in result_dir
vtuneopts+=" -r result_dir"

# if our experiment will collect more than 500MB of data, we'll need to disable
# the default collection size limit (use with care: Vtune collections can get
# **VERY** large!)
#vtuneopts+=" -data-limit=0"

# assemble our srun command:
srun --label -n 1 amplxe-cl $vtuneopts -- ./hack-a-kernel-vtune.ex

