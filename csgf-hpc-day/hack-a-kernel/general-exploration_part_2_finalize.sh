#!/bin/bash

# Where did you tell VTune to save the performance collection?
collection_dir=${SCRATCH}/general-exploration.VTune_general_exploration.6033350

module load vtune

amplxe-cl -finalize \
          -r ${collection_dir} \
          -search-dir=${HOME}/train/csgf-hpc-day/hack-a-kernel \
          -source-search-dir=${HOME}/train/csgf-hpc-day/hack-a-kernel
