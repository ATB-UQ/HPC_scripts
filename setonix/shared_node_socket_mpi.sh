#!/bin/bash --login
 
# SLURM directives
#
# Here we specify to SLURM we want to execute 64 tasks
# for an MPI job that will share the rest of the node with other jobs.
# The plan is to utilise fully 1 of the two sockets available (64 cores) and
# a wall-clock time limit of 24 hours
#
# Replace [your-project] with the appropriate project name
# following --account (e.g., --account=project123)
 
#SBATCH --account=[your-project]
#SBATCH --partition=work
#SBATCH --ntasks=64
#SBATCH --ntasks-per-node=64
#SBATCH --ntasks-per-socket=64
#SBATCH --mem=115G
# --mem specifies total memory for the job
# --mem-per-cpu is not recommended on Setonix as it can create allocation problems
#SBATCH --time=24:00:00
#SBATCH --distribution=block:block:block
# block:block:block option packs threads into contiguous cores
 
# ---
# Load here the needed modules
 
# ---
# Note we avoid any inadvertent OpenMP threading by setting
# OMP_NUM_THREADS=1
export OMP_NUM_THREADS=1
 
# ---
# Run the desired code:
srun  ./code_mpi.x
