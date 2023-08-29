#!/bin/bash --login
#SBATCH --job-name=<JOB_NAME>
#SBATCH --partition=gpu
#SBATCH --nodes=1              #1 nodes in this example
#SBATCH --ntasks-per-node=1    #8 tasks for the 8 GPUs on each node
#SBATCH --gpus-per-node=1      #Use all the GPUs (8) on each node
#SBATCH --sockets-per-node=1   #Use the 8 slurm-sockets on each node
#SBATCH --cpus-per-task=8      #IMPORTANT: Always reserve 8 CPU-cores per task. In this way,
#                                the whole slurm-socket (L3 cache group) will be reserved
#                                for each of the tasks, allowing for correct GPU binding.
#SBATCH --time=24:00:00
#SBATCH --account=<ACCOUNT>-gpu #IMPORTANT: use your own project and the -gpu suffix
#####SBATCH --exclusive                 #All resources on the nodes are exclusive to this job if uncommented

#----
#Loading needed modules (adapt this for your purposes):
module use /software/projects/m72/snada/manual/modules
module load amber/A22-AT23-HIP030123

#----
#Definition of the executable (we assume the example code has been compiled and is available in $MYSCRATCH):
theExe="pmemd.hip.MPI -O -i example.mdin -c example.nc -p example.parm7  -r example.nc -x example.nc -e example.mden -inf example -o example.log"
#----
#                 Here we use ROCR_VISIBLE_DEVICES environment variable fir this purpose
#                 but, depending on the type of application, some other variables may need to be set too
#                 (check documentation).
wrapper="selectGPU_${SLURM_JOBID}.sh"
cat << EOF > $wrapper
#!/bin/bash
 
export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID
exec \$*
EOF
chmod +x ./$wrapper

#----
#Second technique: generate an ordered list of CPU-cores (each on a different slurm-socket)
#                  to be matched with the correct GPU in the srun command using --cpu-bind option.
#                  Script "generate_CPU_BIND.sh" serves this purpose and is available to all users
#                  through the module pawseytools, which is loaded by default.
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


#printenv
#----
#Execution
echo -e "\n\n#------------------------#"
echo "Test code execution using:"
echo "srun -l -u -c 8 --cpu-bind=${CPU_BIND} ./$wrapper ${theExe} | sort -n"
srun -l -u -c 8 --cpu-bind=${CPU_BIND} ./$wrapper ${theExe} | sort -n

#----
#Check with rocm-smi (comment/uncomment as needed):
echo -e "\n\n#------------------------#"
echo "Check with rocm-smi using:"
echo "srun -l -u -c 8 --cpu-bind=${CPU_BIND} ./$wrapper rocm-smi --showhw | sort -n"
srun -l -u -c 8 --cpu-bind=${CPU_BIND} ./$wrapper rocm-smi --showhw | sort -n

#----
#Finalising
rm -f ./$wrapper #deleting the wrapper of the first technique
echo -e "\n\n#------------------------#"
echo "Done"