# CSGF HPC Day - Introduction to Cori

## Exercise 4: Getting the affinity settings right

In this exercise we'll start a small enough number of simultaneous tasks that
each **should** get its own core, and use `ps` in the background to show that
it does not necessarily do so.

In the first step we'll do the experiment quickly using a `sleep` process, then
we'll modify the script to run multiple copies of the hack-a-kernel executable 
we created in [exercise 3](../ex3-building_apps/README.md). This second step 
will take several minutes to run, so we'll submit it now and review the output
later, at your leisure.

### Step 1: A simple placement test with "sleep"

Take a look at `ex4a.sh`. It runs 4 job steps, each with different `srun` 
options, calling `sleep -20` via the `check_placement.sh` script in this 
directory.

Take a look also at the `check_placement,sh` script. There's a lot of `bash`
and `awk` there but what it does is start a command in the background, wait
a few seconds, then capture the output of `ps` and use it to find which cores
are being used.

You can submit the job with:

```console
$ sbatch ex4a.sh
```

Once the job completes, take a look at the `slurm-<job-id>.out` file. In each
experiment, how were the tasks distributed over the cores? Did each task get 
it's own?

### Step 2: Repeat the test using hack-a-kernel

Now look at `ex4b.sh`. It's the same experiments as `ex4a.sh`, but this time 
running hack-a-kernel and capturing the overall run time for all instances.

Note that we're only running 12 at a time now (more won't fit in the memory of
a KNL node) so you might not see cores ebing overcommitted. But you should see 
a difference in the time for the first 2 or 3 `srun` calls, and the final 
`srun`
