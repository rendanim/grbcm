#!/bin/bash 

# Set the allocation to be charged for this job
# not required if you have set a default allocation

# The name of the script is myjob
#SBATCH -J myjob

# Only 0.5 hour wall-clock time will be given to this job
#SBATCH -t 0:30:00

# set the project to be charged for this job
#SBATCH -A edu16.2427

# Number of nodes
#SBATCH --nodes=1
# Number of MPI processes per node (24 is recommended for most cases)
# 48 is the default to allow the possibility of hyperthreading
#SBATCH --ntasks-per-node=24

#SBATCH -e error_file.e
#SBATCH -o output_file.o 

module add cuda matlab matconvnet gcc/5.1 openmpi
# Run the executable named run_cifar.m 
# and write the output into output.out
mpirun -np 1 matlab -nodisplay < script.m > output.out


