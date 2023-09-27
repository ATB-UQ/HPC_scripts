#!/bin/bash --login
#SBATCH --job-name=<JOB_NAME>
#SBATCH --partition=gpu
#SBATCH --nodes=1              #1 nodes in this example
#SBATCH --gpus-per-node=1      #1 GPUs in this job
#SBATCH --time=01:00:00
#SBATCH --account=<ACCOUNT>-gpu

module load gromacs-amd-gfx90a/2023

export OMP_NUM_THREADS=8
export GMX_MAXBACKUP=-1

srun -l -u -N 1 -n 1 -c 8 --gpus-per-node=1 --gpus-per-task=1 gmx_mpi mdrun <ARGS> -nb gpu -bonded gpu
