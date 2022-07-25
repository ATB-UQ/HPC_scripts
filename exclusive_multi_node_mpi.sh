#!/bin/bash --login
 
# SLURM directives
#
# Here we specify to SLURM we want 512 tasks
# distributed by 128 tasks per node (using all available cores in 4 nodes)
# a wall-clock time limit of 24 hours
#
# Replace [your-project] with the appropriate project name
# following --account (e.g., --account=pawsey00XX)
 
#SBATCH --account=[your-project]
#SBATCH --partition=work
#SBATCH --ntasks=512
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --exclusive
 
# ---
# Load here the needed modules
 
# ---
# Note we avoid any inadvertent OpenMP threading by setting
# OMP_NUM_THREADS=1
export OMP_NUM_THREADS=1
 
# ---
# Run the desired code:
srun ./code_mpi.x
# Note that no further details need to be given to srun, as it will take the settings from the allocation indicated in the header.
