#!/bin/bash --login
#SBATCH --job-name=<JOB_NAME>
#SBATCH --account=<ACCOUNT>
#SBATCH --partition=work
#SBATCH --ntasks=256
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --exclusive
#SBATCH --time=10:00:00

module load gromacs/2023
#export GMX_MAXBACKUP=-1

# Temporal workaround for avoiding Slingshot issues on shared nodes:
export FI_CXI_DEFAULT_VNI=$(od -vAn -N4 -tu < /dev/urandom)
export MPICH_OFI_STARTUP_CONNECT=1

export OMP_NUM_THREADS=8

export NRANK=$(($SLURM_NTASKS/$OMP_NUM_THREADS))

srun -N $SLURM_JOB_NUM_NODES -n $NRANK -c $OMP_NUM_THREADS -m block:block:block gmx_mpi_d mdrun <ARGS>
