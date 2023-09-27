#!/bin/bash --login
#SBATCH --job-name=PyThinFilm_Example
#SBATCH --partition=gpu
#SBATCH --nodes=4
#SBATCH --gpus-per-node=8
#SBATCH --time=1:00:00
#SBATCH --account=m72-gpu

module load gromacs-amd-gfx90a/2023
module load python/3.10.10

export OMP_NUM_THREADS=8
export GMX_MAXBACKUP=-1
srun -l -u -N 4 -n 32 -c 8 --gpus-per-node=8 --gpus-per-task=1 --gpu-bind=closest gmx_mpi mdrun <ARGS> -nb gpu -bonded gpu
