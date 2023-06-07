#!/bin/bash
#SBATCH --job-name=EXAMPLE
#SBATCH --partition=gpu
#SBATCH --nodes=1 --ntasks-per-node=28
#SBATCH --gres=gpu:tesla-smx2:4 # use this for newer nodes with 4 gpus per node
#####SBATCH --gres=gpu:1 #use this for one gpu on any node
#####SBATCH --gres=gpu:tesla:2 #use this for slower nodes with 2 gpus per node
#SBATCH --mem-per-cpu=1G
#SBATCH --error=error_messages.log
#SBATCH --output=standard_output.log

#Load Modules

# -n4 = 4 GPU. Should be the same as the number of GPUs available, not the number of CPUs available.
#mpi= id of mpi library used, full list available here: https://slurm.schedmd.com/srun.html
srun -n4 --mpi=mpi_type EXECUTABLE_FLAGS_AND_ARGUMENTS