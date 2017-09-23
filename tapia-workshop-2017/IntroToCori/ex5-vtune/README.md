# TAPIA Conference 2017 - Introduction to Cori

## Exercise 5: Building and running with Vtune

Later today we'll optimize hack-a-kernel for KNL. The first step in 
optimization is to understand the current performance, and for this we'll use
[Intel] [Vtune]. In preparation, let's build hack-a-kernel with support for
Vtune, and run a general HPC Performance  analysis experiment.

[Intel]: https://software.intel.com/en-us/intel-vtune-amplifier-xe
[Vtune]: http://www.nersc.gov/users/software/performance-and-debugging-tools/vtune/

### Step 1: Environmental considerations

At NERSC, the `darshan` module is loaded into your environment by default. This
provides low-overhead I/O performance measurement.

However, performance measurement tools typically interfere with each other, so 
to use Vtune we'll first unload darshan:

```console
$ module list
Currently Loaded Modulefiles:
...
 11) gni-headers/5.0.11-2.2                       23) darshan/3.1.4
 12) xpmem/2.1.1_gf9c9084-2.38
$ module unload darshan
$ module list
...
```

You will also need to unload darshan in your job script (as we'll see below).

### Step 2: Build the application

VTune requires that the executable be dynamically linked. On a typical cluster
or Linux workstation this is the default, but at scale dynamic linking has a 
performance penalty so Cray systems such as Cori use static linking. We can 
override the static linking with `-dynamic` on the command line.

Vtune will give more helpful results if debugging information is included in 
the executable, so we'll add `-g` to the command line. A side effect of `-g` is
to set the optimization level to zero, so we'll return it to the default of 
`-O2` explicitly. Finally, if your application uses inlined functions, adding 
`-debug inline-debug-info` is helpful.

First, we'll copy the source code into our current directory:

```console
$ cp ../../hack-a-kernel/hack-a-kernel.f90 .
```

```console
$ ftn -g -debug inline-debug-info -O2 -qopenmp \
      -dynamic -parallel-source-info=2 \
      -qopt-report-phase=vec,openmp \
      -o hack-a-kernel-vtune.ex hack-a-kernel.f90
```

### Step 3: Run the application

Our job script needs a couple of extra options:

- Vtune uses a kernel module to access uncore counters. We can insert the 
  module on our nodes by adding the `--perf=vtune` option to sbatch
- Don't forget to unload darshan!
- To access Vtune, we must load its module
- Vtune uses file locking, which is not supported on $HOME or /project 
  filesystems at NERSC, so we **must** run from $SCRATCH

```bash
#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --perf=vtune             # use Vtune
#SBATCH --reservation=tapia  # our reservation today

module unload darshan
module load vtune

# if we are not in $SCRATCH, abort:
[[ $PWD =~ ^$SCRATCH ]] || { echo "must run in \$SCRATCH" ; exit 2 ; }

# set the Vtune collection options we want:
# A good starting point is the 'hpc-performance' experiment:
vtuneopts="-collect hpc-performance"
# Extension: another good starting point is:
#vtuneopts="-collect general-exploration"
# If you try this, be sure to make a new result_dir for it (see below)!

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

```

In order for Slurm to find the correct Vtune kernel module, we must have vtune
loaded in our environment before submitting the job:

```console
$ module load vtune
$ sbatch ex5.sh
Submitted batch job 6020460
```

### Step 4: Finalize the results

Once the job is complete, if everything worked you should see a directory 
`result_dir`. We'll prepare those results for viewing in the GUI (later today) 
with:

```console
$ amplxe-cl -finalize -finalization-mode=full -r result_dir -search-dir $PWD
amplxe: Using result path `/global/cscratch1/sd/mamelara/tapia-2017/tapia-workshop-2017/IntroToCori/ex5-vtune/result_dir'
amplxe: Executing actions 39 % Resolving information for dangling locations
amplxe: Warning: The current result was collected on another host. For proper symbol resolution, please specify search directories for the binaries of interest using the -search-dir command line option or "Binary/Symbol Search" dialog in GUI.
...
amplxe: Executing actions 100 % done
```

The warnings about result being collected on another host are harmless, this
will also lead to harmless warnings about being unable to find certain files.

We'll stop here, and analyse the results this afternoon

### Optional extra

In case you can't resist - you can get a text performance report at the command
line with: 

```console
$ amplxe-cl -r result_dir -report summary
```
