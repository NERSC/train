#!/bin/bash
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --perf=vtune             # use Vtune
#SBATCH --reservation=csgftrain
#SBATCH -J VTune_hotspots
#SBATCH -o VTune_hotspots.%j.out

# darshan and VTune don't play nicely together, so unload darshan.
module unload darshan
module load vtune

# set the Vtune collection options we want:
# A good starting point is the 'general-exploration' experiment:
vtuneopts="-collect hotspots"
# If you try this, be sure to make a new result_dir for it (see below)!

# By default Vtune "finalizes" (collates and prepares) its results at the end
# of each run. This procedure is serial and slow - not a good use of compute
# node time in any case, and even worse on KNL as the type of workload is not
# suited to the KNL architecture. So we'll defer finalization and do it on the
# command line later:
vtuneopts+=" -finalization-mode=deferred"

# VTune doesn't target MPI programs, but if you are analysing an MPI program
# it is best to let Vtune know: (we don't need this today)
#vtuneopts+=" -trace-mpi"

# We'll put the Vtune results in result_dir
vtuneopts+=" -r ${SCRATCH}/hotspots.${SLURM_JOB_NAME}.${SLURM_JOB_ID}"

# if our experiment will collect more than 500MB of data, we'll need to disable
# the default collection size limit (use with care: Vtune collections can get
# **VERY** large!)
#vtuneopts+=" -data-limit=0"

# Enable detailed profiling data for OpenMP regions.
vtuneopts+=" -knob analyze-openmp=true"

# If we are using OpenMP, set the number of threads and thread binding
# parameters.
OMP_NUM_THREADS=68
OMP_PROC_BIND=spread
OMP_PLACES=cores

# assemble our srun command:
srun -n 1 -c 272 --cpu_bind=sockets amplxe-cl $vtuneopts -- ${HOME}/train/csgf-hpc-day/hack-a-kernel/hack-a-kernel-vtune.ex
