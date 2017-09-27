# KNL hackathon example code

## Compile:

### Step 1: Environmental considerations

At NERSC, the `darshan` module is loaded into your environment by default. This
provides low-overhead I/O performance measurement.

However, performance measurement tools typically interfere with each other, so 
to use CrayPat we'll first unload darshan:

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

```console
$ module swap craype-haswell craype-mic-knl
$ module unload darshan
$ module load perftools-base perftools-lite
$ ftn -g -O2 -qopenmp \
      -qopt-report -qopt-report-phase=vec,openmp \
      -o hack-a-kernel.ex ../hack-a-kernel.f90
```

## Run:

Make a job script (`hackathon.sh`) like:

```bash
#!/bin/bash
#SBATCH -N 1                     # Use 1 node
#SBATCH -t 10                    # Set 10 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes
#SBATCH --reservation=tapia      # our reservation today

module unload darshan
module load perftools-base perftools-lite

srun -n 1 ./hack-a-kernel.ex
```

Submit it like:

```console
$ sbatch hackathon.sh
Submitted batch job 6018089
```

## Check results:

Results will appear in a `slurm-*.out` file in the current directory. They
include run time for 3 sections and overall, and an answer. The timing may 
vary, but the answers should be very close to:

```console
$ cat slurm-6018089.out
Starting loop
Runtime:   83.7500000000000
Runtime A:  0.181999998632818
Runtime B:   80.7530000004917
Runtime C:   2.80499999970198
Answer: (-16862103.1278241,0.000000000000000E+000)
(-36828835.9338165,-14463922.8990243)
```

There will also be a new directory created in the same directory from which you
submitted the job, called something like "hack-a-kernel.ex+68738-2516s" (the
numbers may be different in your case). This contains the profiling data for
the hack-a-kernel program. You can view the data by running the "pat_report"
command on the directory, e.g.:

```console
pat_report hack-a-kernel.ex+68738-2516s # (change the dir name as necessary)
```

This will print a lot of text to the screen. The part that will be of most
interest is Table 2, the region where it shows which lines of the code consumed
the most amount of time.

It is convenient to redirect this output to a text file so that you can look
through it with a text editor:

```console
pat_report hack-a-kernel.ex+68738-2516s > hack-a-kernel_profiling_report.txt
```

 
