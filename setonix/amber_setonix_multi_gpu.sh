#!/bin/bash --login
#SBATCH --job-name=<jobname>
#SBATCH --partition=gpu
#SBATCH --nodes=1              #1 nodes in this example
#SBATCH --gpus-per-node=8      #Use all the GPUs (8) on each node
#SBATCH --time=02:00:00
#SBATCH --account=<account>-gpu #IMPORTANT: use your own project and the -gpu suffix
#SBATCH --exclusive                 #All resources on the nodes are exclusive to this job

#----
#Loading needed modules (adapt this for your purposes):
module use /software/projects/m72/snada/manual/modules
module load amber/A22-AT23-HIP030123

#----
#Definition of the executable
theExe="pmemd.hip.MPI -O -i mdin -o mdout -p prmtop -c inpcrd"
#---- Needed for "manual" optimal binding of GPUs and chiplets
#First "aux technique": create a selectGPU wrapper to be used for
#                       binding only 1 GPU per each task spawned by srun
#                       Here we use ROCR_VISIBLE_DEVICES environment variable for this purpose
#                       but, depending on the type of application, some other variables may need to be set too
#                       (check documentation).
wrapper="selectGPU_${SLURM_JOBID}.sh"
cat << EOF > $wrapper
#!/bin/bash

export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID
exec \$*
EOF
chmod +x ./$wrapper

#---- Needed for "manual" optimal binding of GPUs and chiplets
#Second "aux technique": generate an ordered list of CPU-cores (each on a different slurm-socket)
#                        to be matched with the correct GPU in the srun command using --cpu-bind option.
#                        Script "generate_CPU_BIND.sh" serves this purpose. This script is available
#                        to all users through the module pawseytools, which is loaded by default.
CPU_BIND=$(generate_CPU_BIND.sh map_cpu)
lastResult=$?
if [ $lastResult -ne 0 ]; then
   echo "Exiting as the map generation for CPU_BIND failed" 1>&2
   rm -f ./$wrapper #deleting the wrapper
   exit 1
fi
echo -e "\n\n#------------------------#"
echo "The chosen CPU_BIND is:"
echo "CPU_BIND=$CPU_BIND"

#----
#MPI & OpenMP settings
export MPICH_GPU_SUPPORT_ENABLED=1 #This allows for GPU-aware MPI communication among GPUs
export OMP_NUM_THREADS=1           #This controls the real CPU-cores per task for the executable

#----
#Execution
##Note: srun needs the explicit indication full parameters for use of resources in the job step.
#      These are independent from the allocation parameters (which are not inherited by srun)
#      For "manual" binding you should NOT use "--gpus-per-task" NOR "--gpu-bind"
#      "--cpu-bind=${CPU_BIND} ./$wrapper" create the optimal binding of GPUs "manually"
echo -e "\n\n#------------------------#"
echo "Test code execution:"
srun -l -u -N 1 -n 8 -c 8 --gpus-per-node=8 --cpu-bind=${CPU_BIND} ./$wrapper ${theExe} | sort -n
