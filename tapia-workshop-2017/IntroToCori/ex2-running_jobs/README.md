# TAPIA Conference - Introduction to Cori

## Exercise 2: Running jobs

Cori uses the Slurm batch system. A job script is a regular shell script 
decorated at the beginning of the script with `#SBATCH` directives. All 
directives must appear before any shell commands (comments and blank lines are 
ok), and anything specified in an `#SBATCH` directive may alteratively be 
specified as a command-line option

To start an interactive session via Slurm, jump down to [Interactive Jobs]

All batch jobs on Cori must specify:

- the number of nodes required (`#SBATCH -N 1`)
- the wallclock time required, in minutes (`#SBATCH -t 10`)
- the type of nodes required (`#SBATCH -C haswell` or `#SBATCH -C knl`).
  For today's exercises we will use knl nodes, and we have a reservation to 
  avoid waiting in the queue. More on using this below
- The filesystems required (`#SBATCH -L SCRATCH`)

The queues on Cori can be very long, so for today we have a number of nodes
reserved under a reservation name of "tapia". To use this reservation we
add the directive `#SBATCH --reservation=tapia`

For KNL nodes you can specify the memory mode, don't worry too much about what 
this means. For today we will use the default mode (which at NERSC is 
`quad,cache`), and the nodes in our reservation have rebooting disabled, so
we will use `#SBATCH -C knl` for all of our exercises
 
Your batch script will be run on the first node allocated to your job, to run
a command on all nodes in the job you must use `srun`. `srun` also performs 
the role of `mpirun` for running MPI jobs.

So a typical job script will look like:

```bash
#!/bin/bash -l
#SBATCH -N 2                     # Use 2 nodes
#SBATCH -t 5                     # Set 5 minute time limit
#SBATCH -L SCRATCH               # Job requires $SCRATCH file system
#SBATCH -C knl                   # use KNL nodes

# directives can be commented out: 
##SBATCH --reservation=tapia  # our reservation today

mkdir -p $SCRATCH/tapia-2017/tapia-workshop-2017/IntroToCori/ex2-running_jobs
# after the first shell command, #SBATCH directives are ignored
cd $SCRATCH/tapia-2017/tapia-workshop-2017/IntroToCori/ex2-running_jobs

# everything up until now ran only on the first node. To run a command in each
# task (ie possibly more than one per node), we use srun:

ntasks=10
srun --label -n $ntasks bash -c 'printf "%s\n" "hello from `uname -n`"'
```

### Step 1: Write (or at least read) the job script

In this directory is a file named `my_first_job.sh`. Look at the file and 
satisfy yourself that you understand what each line does.

From the command line, submit the job:

```console
$ sbatch my_first_job.sh
Submitted batch job 5468709
```

That final number is the job ID, which we'll use to identify this job in later 
commands

### Step 2: Check on the progress of your job

You can check on the progress of your jobs with `sqs`:

```console
$ sqs
JOBID              ST   REASON       USER         NAME         NODES        USED         REQUESTED    SUBMIT                PARTITION    RANK_P       RANK_BF
5468709            PD   Priority     mamelara        my_first_jo  2         0:00         5:00         2017-06-22T11:25:20   debug        16943        N/A
```

If the `ST` field is `PD`, your job is still in the queue. If it is `R`, 
your job is running. If your job does not appear in the `sqs` output then
it has completed (hopefully successfully), and you should see a file in the
directory you submitted from like `slurm-5468709.out`:

```console
$ sqs
JOBID              ST   REASON       USER         NAME         NODES        USED         REQUESTED    SUBMIT                PARTITION    RANK_P       RANK_BF
$ ls -lt
total 12
-rw-rw---- 1 mamelara staff  172 Jun 22 11:34 slurm-5468709.out  
...
```

Take a look inside that file to see the output and any errors from your job:

```console
$ less -FX slurm-5468709.out
running a simple command in /global/cscratch1/sd/sleak/test_my_account
total 4
-rw-rw---- 1 mamelara mamelara 115 Jun 22 11:34 stdout
1: hello from nid00509
2: hello from nid00509
0: hello from nid00509
4: hello from nid00521
3: hello from nid00521
  ...
```

See http://www.nersc.gov/users/computational-systems/cori/running-jobs/ for 
more about running jobs


## Extension: Interactive Jobs

You can start an interactive job on Cori with `salloc`. `salloc` takes (and 
requires) the same arguments as `sbatch`:

- the number of nodes required (`-N 1`)
- the wallclock time required, in minutes (`-t 10`)
- the type of nodes required (`-C haswell` or `-C knl`).
- The filesystems required (`-L SCRATCH`)
- In sessions with a reservation, specify the reservation with 
  `--reservation=name_of_reservation`

So to start an interactive session using KNL nodes today (using our `tapia` 
reservation):

```console
  $ salloc -C knl --reservation=tapia -N 1 -t 30 -L SCRATCH
```
