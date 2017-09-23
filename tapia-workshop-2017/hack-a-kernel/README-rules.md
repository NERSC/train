# Tapia 2017 - Optimization Challenge on Cori (Hackathon)

We recommend working in teams of 2-3 people

## Compile:

```console
$ module swap craype-haswell craype-mic-knl
$ module unload darshan
$ module load perftools-base perftools-lite
$ ftn -g -O2 -qopenmp \
      -qopt-report -qopt-report-phase=vec,openmp \
      -o hack-a-kernel.ex hack-a-kernel.f90
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

## Optimize the code:

### Rules:

- Run on a single KNL compute node.
- You may add OpenMP (or another shared-memory parallelism model), but not MPI
- Don't change the value of parameter or array initialized at the top of the 
  program. 
- Don't change the overall timer (the individual code section timers can be 
  moved and are there just to help you get started)
- You can change the order of the loops and operations, but you can not change
  the function on the code. i.e. it must give the same answer, even if values 
  in arrays were to change. 

### Tips:

- Consider compiler options, optimization settings
- Remember the affinity exercises from this morning

## Submit your results:

At 4.45pm (15 minutes before the end of the day) we'll announce the end of 
the hackathon, at which point you have 5 minutes to send us your best result.
At 4.50pm we'll we'll announce the winner for the day!

For the format of your best result, please send an email:

```
To: bfriesen@lbl.gov, djbard@lbl.gov, mamelara@lbl.gov
Subject: Hackathon result, team $choose_a_name
Body:
  Team members' names: 
  Paste of your best result (overall time and answer)
  Path on Cori where we can check your optimization of the code: (full path!)
  Are you ok with us sending your ideas around to the other participants later?
  Would you like to see how other teams achieved good results? (via email later)
```

Good luck, and have fun!
 
