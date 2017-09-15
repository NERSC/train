# TAPIA Conference 2017 - Introduction to Cori

## Exercise 3: Building applications

### Environment modules and Cray compiler wrappers

Software on Cori is managed through Environment modules. To see a list of
available software use `module avail`. Loading an unloading modules updates
your PATH and other environment variables to make the software available for 
use. To see exactly what a module does use `module show some_module_name`. To
add a module to your environment use `module load some_module_name`. To
remove it from your environment use `module unload some_module_name`. To see
which modules you currently have loaded use `module list`.

Compiling on the Cray is done with the compiler wrappers, `cc` for C, `CC` for
C++ and `ftn` for Fortran. Many high-level compilation options are set based on 
the modules you have loaded, especially:

- The underlying compiler is set by the `PrgEnv-*` module you have loaded. At
  NERSC we load `PrgEnv-intel` by default, so the compiler wrapeprs call 
  `icc`, `icpc` or `ifort` as appropriate. For today, we will stick with this
  default
 
- The target CPU architecture is set by loading one of `craype-haswell` or 
  `craype-mic-knl`. At NERSC `craype-haswell` is loaded by default, also the
  login nodes have Haswell CPUs. 
  It is important to remember that when building for KNL we are 
  cross-compiling - the executable will have instructions that Haswell does 
  not support

**NOTE:** This execise assumes you are in the same directory as this README.md!

### Step 1: Build and run the hack-a-kernel code

We will use this mini-application in the KNL Optimization Challenge this 
afternoon, so let's build and run the unoptimized, serial code. First we'll
make sure we're building for KNL:

```console
$ module list
Currently Loaded Modulefiles:
...
  6) cray-libsci/16.09.1                          18) PrgEnv-intel/6.0.3
  7) udreg/2.3.2-7.54                             19) craype-haswell
...
$ module avail craype-
...
craype-accel-nvidia35 craype-hugepages2M    craype-ivybridge
craype-accel-nvidia60 craype-hugepages32M   craype-mic-knl
craype-haswell        craype-hugepages512M  craype-network-none
...
$ module swap craype-haswell craype-mic-knl
$ module list
Currently Loaded Modulefiles:
...
  6) cray-libsci/16.09.1                          18) PrgEnv-intel/6.0.3
  7) udreg/2.3.2-7.54                             19) craype-mic-knl
...
```

And copy the source code over:
```console
cp ../../hack-a-kernel/hack-a-kernel.f90 .
```

This is a single-file application so we won't bother with a makefile:

```console
$ ftn -o hack-a-kernel-v0.ex hack-a-kernel.f90
```

If you try to run the executable on the login node, you'll see an error:

```console
$ ./hack-a-kernel-v0

Please verify that both the operating system and the processor support Intel(R) AVX512F, ADX, RDSEED, AVX512ER, AVX512PF and AVX512CD instructions.

```

We'll write a job script (call it `ex3a.sh`) to run the kernel on a compute 
node:

```bash
#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=tapia  # our reservation today

# Slurm will start us in the directory we submitted the job
# srun is not strictly necessary here (it's a serial job), but we'll get
# into the habit of using it:

srun --label -n 1 ./hack-a-kernel-v0.ex
```

Now submit the job and check for output:

```console
$ sbatch ex3a.sh
Submitted batch job 6018089
$ sqs
JOBID              ST   REASON       USER         NAME         NODES        USED         REQUESTED    SUBMIT                PARTITION    RANK_P       RANK_BF
6018089            PD   Priority     sleak        ex3a.sh      1            0:00         10:00        2017-07-25T10:50:59   knl          8578         N/A
$ #wait till job completes
$ cat slurm-6018089.out
0:  Starting loop
0:  Runtime:   83.7500000000000
0:  Runtime A:  0.181999998632818
0:  Runtime B:   80.7530000004917
0:  Runtime C:   2.80499999970198
0:  Answer: (-16862103.1278241,0.000000000000000E+000)
0:  (-36828835.9338165,-14463922.8990243)
```

Once the job completes you should see a file like ...FIXME

### Step 2: Build and run a simple MPI job

Our MPI example is simpler still - ue your favorite editor to take a look at 
the code, then build it: (notice that this example is in C++)

```console
$ CC -o hello-mpi.ex hello-mpi.c++
```

This time out job script will use 2 nodes, and run 2 MPI tasks on each. We'll
call this one `ex3b.sh`:

```bash
#!/bin/bash -l
#SBATCH -N 2                     # Use 2 nodes
#SBATCH -t 5                     # Set 5 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=tapia  # our reservation today

nnodes=2
ntasks=4

srun --label -N $nnodes -n $ntasks ./hello-mpi.ex 
```

Now submit the job and check for output:

```console
$ sbatch ex3b.sh
Submitted batch job 6018189
$ sqs
JOBID              ST   REASON       USER         NAME         NODES        USED         REQUESTED    SUBMIT                PARTITION    RANK_P       RANK_BF
6018189            PD   Priority     mamelara     ex3b.sh      2            0:00         5:00         2017-07-25T11:02:08   knl          7946         N/A
```

You should see a message from each of 4 tasks, 2 on each node.

```console
$ cat slurm-6018189.out
0: Hello world from process 0 of 4
3: Hello world from process 3 of 4
2: Hello world from process 2 of 4
1: Hello world from process 1 of 4
```

### Step 3: Build and run a simple OpenMP job

For our final example, we'll build and run an OpenMP code (this one is in C):

```console
$ cc -qopenmp -o hello-omp.ex hello-omp.c
```

Let's call the job script for this one `ex3c.sh`:

```bash
#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 5                     # Set 5 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=tapia  # our reservation today

export OMP_NUM_THREADS=5
srun --label -n 1 ./hello-omp.ex
```

Again, submit the job and check for output:

```console
$ sbatch ex3c.sh
Submitted batch job 6018233
$ sqs
JOBID              ST   REASON       USER         NAME         NODES        USED         REQUESTED    SUBMIT                PARTITION    RANK_P       RANK_BF
6018233            PD   Priority     mamelara     ex3c.sh      1            0:00         5:00         2017-07-25T11:08:15   knl          9945         N/A
$ # wait ...
$ cat slurm-6018233.out
0: Hello World from thread = 2
0: Hello World from thread = 1
0: Hello World from thread = 0
0: Number of threads = 5
0: Hello World from thread = 3
0: Hello World from thread = 4
```

Note that each line is labelled as coming from the same `srun` task, despite 
coming from different threads. Also note that the order is not gaurenteed!

