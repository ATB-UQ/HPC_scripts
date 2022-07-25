#!/bin/bash --login
 
# SLURM directives
#
# Here we specify to SLURM we want an OpenMP job with 128 threads
# a wall-clock time limit of one hour.
#
# Replace [your-project] with the appropriate project name
# following --account (e.g., --account=project123).
 
#SBATCH --account=[your-project]
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --time=01:00:00
#SBATCH --exclusive
# Exclusive flag uses entire node
 
# ---
# Load here the needed modules
 
# ---
# OpenMP settings
export OMP_NUM_THREADS=128  #To define the number of threads
export OMP_PROC_BIND=close  #To bind (fix) threads (allocating them as close as possible)
export OMP_PLACES=cores     #To bind threads to cores
 
# ---
# Run the desired code:
srun ./code_omp.x
# Note that no further details need to be given to srun, as it will take the settings from the allocation indicated in the header.
