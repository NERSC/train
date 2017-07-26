#!/bin/bash

# Where did you tell VTune to save the performance collection?
collection_dir=${SCRATCH}/memory-access.VTune_memory-access.6033578

module load vtune

amplxe-cl -finalize \
          -r ${collection_dir} \
          -search-dir=${HOME}/train/csgf-hpc-day/hack-a-kernel \
          -source-search-dir=${HOME}/train/csgf-hpc-day/hack-a-kernel
