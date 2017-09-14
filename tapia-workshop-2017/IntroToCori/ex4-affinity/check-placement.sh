#!/bin/bash

# start a command, and after a few seconds use 'ps' to see which core it is on:

# in the presence of hyperthreading, the mapping of cpu id to core id is:
# (example of 4 cores and 2 hyperthreads)
#     cpu: 0 1 2 3 4 5 6 7
#    core: 0 1 2 3 0 1 2 3

# we can use awk to extract the number of cpus, and the threads per core, from lscpu,
# and from that find the number of cores:
awktpc='/^Thread\(s\) per core/ {tpc=$NF}'
awkcpus='/^CPU\(s\):/ {cpus=$NF}'
ncores=$(lscpu | awk "$awktpc $awkcpus END {print cpus/tpc}")

# run the command in the background, and capture its pid:
cmd="$*"
[[ -z $cmd ]] && cmd="sleep 20"
$cmd &
pid=$!

# wait several seconds for tasks to start, then check placement:
sleep 15

awkcore="{ core=int(\$1%$ncores) ; printf(\"%4i %s\n\",core,\$0) }"
placement=$(ps h H --pid $pid -o psr,tid,pid,time,comm | awk "$awkcore")
# only print the header from the first task on a node:
[[ $SLURM_LOCALID -eq 0 ]] && echo "core PSR    TID    PID     TIME COMMAND" 1>&2

# wait for the actual command to complete:
wait

# now print the core report to stderr:
echo "$placement" 1>&2

