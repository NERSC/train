## Exercise 2: Building applications for KNL

### Environment modules and Cray compiler wrappers

Compiling on the Cray is done with the compiler wrappers, `cc` for C, `CC` for
C++ and `ftn` for Fortran. Many high-level compilation options are set based on 
the modules you have loaded, especially:

- The underlying compiler is set by the `PrgEnv-*` module you have loaded. At
  NERSC we load `PrgEnv-intel` by default, so the compiler wrapeprs call 
  `icc`, `icpc` or `ifort` as appropriate. For today, we will stick with this
  default
 
- The target CPU architecture is set by loading one of `craype-haswell` or 
  `craype-mic-knl`. At NERSC `craype-haswell` is loaded by default, also the
  login nodes have Haswell CPUs. Since we are building for KNL, we'll swap the
  `craype-haswell` module for the `craype-mic-knl` one.
  It is important to remember that when building for KNL we are 
  cross-compiling - the executable will have instructions that Haswell does 
  not support

**NOTE:** This execise assumes you are in the same directory as this README.md!

### Step 1: Build and run the hack-a-kernel code

First we'll make sure we're building for KNL:

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
cp ../hack-a-kernel/hack-a-kernel.f90 .
```

This is a single-file application so we won't bother with a makefile:

```console
$ ftn -o hack-a-kernel-v0.ex hack-a-kernel.f90
```

If you try to run the executable on the login node, you'll see an error:

```console
$ ./hack-a-kernel-v0.ex

Please verify that both the operating system and the processor support Intel(R) AVX512F, ADX, RDSEED, AVX512ER, AVX512PF and AVX512CD instructions.

```

We'll write a job script (call it `ex2.sh`) to run the kernel on a compute 
node:

```bash
#!/bin/bash -l
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes

# Slurm will start us in the directory we submitted the job
# srun is not strictly necessary here (it's a serial job), but we'll get
# into the habit of using it:

srun --label -n 1 ./hack-a-kernel-v0.ex
```

Now submit the job and check for output:

```console
$ sbatch ex2.sh
Submitted batch job 6018089
$ sqs
JOBID              ST   REASON       USER         NAME         NODES        USED         REQUESTED    SUBMIT                PARTITION    RANK_P       RANK_BF
6018089            PD   Priority     mamelara     ex2.sh      1            0:00         10:00        2017-07-25T10:50:59   knl          8578         N/A
```

Once the job completes you should see a file like slurm-<job-id>.out

```console
$ cat slurm-6018089.out
0:  Starting loop
0:  Runtime:   83.7500000000000
0:  Runtime A:  0.181999998632818
0:  Runtime B:   80.7530000004917
0:  Runtime C:   2.80499999970198
0:  Answer: (-16862103.1278241,0.000000000000000E+000)
0:  (-36828835.9338165,-14463922.8990243)
```

