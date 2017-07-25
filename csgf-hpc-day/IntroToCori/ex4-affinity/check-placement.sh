#!/bin/bash

# start a command, and after a few seconds use 'ps' to see which core it is on:

# in the presence of hyperthreading, the mapping of cpu id to core id is:
# (example of 4 cores and 2 hyperthreads)
#     cpu: 0 1 2 3 4 5 6 7
#    core: 0 1 2 3 0 1 2 3

# we can use awk to extract the number of cpus, and the threads per core, from lscpu,
# and from that find the number of cores:
awktpc='/^Thread\(s\) per core/ {tpc=$NF}'
awkcpus='/^CPU\(s\):/ {cpus=$NF} END {print cpus/tpc}'
ncores=$(lscpu | awk "$awktpc $awkcpus END {print cpus/tpc}")

# run the command in the background, and capture its pid:
cmd="$*"
[[ -z $cmd ]] && cmd="sleep 10"
$cmd &
pid=$!

# wait a few seconds then check placement:
sleep 5

# only print the header from the first task on a node:
[[ $SLURM_LOCALID -eq 0 ]] && echo "core PSR    TID    PID     TIME COMMAND" 
awkcore="{ core=int(\$1%$ncores) ; printf(\"%4i %s\n\",core,\$0) }"
ps h H --pid $pid -o psr,tid,pid,time,comm | awk "$awkcore" | sort -n

# wait for the actual command to complete:
wait

