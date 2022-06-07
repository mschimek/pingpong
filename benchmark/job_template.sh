#!/bin/bash

#SBATCH -o PATH_TO_BE_REPLACED/output/2.txt
#SBATCH --open-mode=append
#SBATCH -e PATH_TO_BE_REPLACED/output/err_2.txt
#SBATCH --mem=80000mb
#SBATCH --ear=off
#SBATCH --switches=1
#SBATCH --nodes=NUM_NODES_TO_BE_REPLACED
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=TASKS_PER_NODE_TO_BE_REPLACED


num_bytes_start=NUM_BYTES_START
num_bytes_stop=NUM_BYTES_STOP
stepsize=STEPSIZE_TO_BE_REPLACED
iterations=ITERATIONS_TO_BE_REPLACED
id=ID_TO_BE_REPLACED
path=PATH_TO_BE_REPLACED

function execute() {
  executable="${path}/pingpong"
    mpiexec -n $SLURM_NTASKS ${executable}            \
      --iterations ${iterations}                      \
      --num_bytes_start ${num_bytes_start}            \
      --num_bytes_stop ${num_bytes_stop}              \
      --stepsize ${stepsize}                          \
      --id ${id}                                      \

    #prevent some MPI failures if two calls to mpiexec without a break
    sleep 15
  }


module load slurm_setup

execute
