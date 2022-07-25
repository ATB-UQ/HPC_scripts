#!/bin/bash --login
 
# SLURM directives
#
# Here we specify to SLURM we want an OpenMP job with 32 threads
# a wall-clock time limit of one hour.
#
# Replace [your-project] with the appropriate project name
# following --account (e.g., --account=project123).
 
#SBATCH --account=[your-project]
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
# use multiples of 8 CPUs (the number of cores per chiplet of the processor) for best L3 cache utilisation
#SBATCH --mem=57440M
# --mem specifies total memory for the job
# --mem-per-cpu is not recommended on Setonix as it can create allocation problems
#SBATCH --time=01:00:00
 
# ---
# Load here the needed modules
 
# ---
# OpenMP settings
export OMP_NUM_THREADS=32   #To define the number of threads
export OMP_PROC_BIND=close  #To bind (fix) threads (allocating them as close as possible)
export OMP_PLACES=cores     #To bind threads to cores
 
# ---
# Run the desired code:
srun –m block:block:block ./code_omp.x
# -m block:block:block option packs threads into contiguous cores
