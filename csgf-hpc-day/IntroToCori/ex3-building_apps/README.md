# CSGF HPC Day - Introduction to Cori

## Exercise 3: Building applications

### Environment modules and Cray compiler wrappers

Software on Cori is managed through Environment modules. To see a list of
available software use `module avail`. Loading an unloading modules updates
your PATH and other environment variables to make the software available for 
use. To see exactly what a module does use `module show some_module_name`. To
add a module to your environment use `module load some_module_name`. To
remove it from your environment use `module unload some_module_name`. To see
which modules you currently have loaded uyse `module list`.

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


### Step 1: Build and run the hack-a-kernel code

We will use this mini-application in the KNL Optimization Challenge this 
afternoon, so let's build and run the unoptimized, serial code. First we'll
make sure we're building for KNL:

```console
$ module list
FIXME 
$ module avail craype-
FIXME
$ module swap craype-haswell craype-mic-knl
$ module list
FIXME 
```

This is a single-file application so we won't bother with a makefile:

```console
$ cd FIXME
$ ftn -o hack-a-kernel-v0.ex hack-a-kernel.f90
```

If you try to run the executable on the login node, you'll see an error:

```console
$ ./hack-a-kernel
FIXME
```

We'll write a job script (call it `ex3a.sh`) to run the kernel on a compute 
node:

```bash
#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=csgftrain  # our reservation today

# Slurm will start us in the directory we submitted the job
# srun is not strictly necessary here (it's a serial job), but we'll get
# into the habit of using it:

srun --label -n 1 ./hack-a-kernel-v0.ex
```

Now submit the job and check for output:

```console
$ sbatch ex3a.sh
FIXME
$ sqs
```

Once the job completes you should see a file like ...FIXME

### Step 2: Build and run a simple MPI job

Our MPI example is simpler still - ue your favorite editor to take a look at 
the code, then build it: (notice that this example is in C++)

```console
$ cd FIXME
$ CC -o hello-mpi.ex hello-mpi.c++
```

TODO check, does running the serial job on login node make the mpi error, or
an unknown instruction one? If it doesn't make the MPI error, use this example
to demo that

This time out job script will use 2 nodes, and run 2 MPI tasks on each. We'll
call this one `ex3b.sh`:

```bash
#!/bin/bash -l
#SBATCH -N 2                     # Use 2 nodes
#SBATCH -t 5                     # Set 5 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=csgftrain  # our reservation today

nnodes=2
ntasks=4

srun --label -N $nnodes -n $ntasks ./mpi-hello.ex 
```

Now submit the job and check for output:

```console
$ sbatch ex3b.sh
FIXME
$ sqs
```

You should see a message from each of 4 tasks, 2 on each node.

### Step 3: Build and run a simple OpenMP job

For our final example, we'll build and run an OpenMP code (this one is in C):

```console
$ cc -o hello-omp.ex hello-omp.c
```

Let's call the job script for this one `ex3c.sh`:

```bash
#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 5                     # Set 5 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=csgftrain  # our reservation today

export OMP_NUM_THREADS=5
srun --label -n 1 ./hello-omp.ex
```


