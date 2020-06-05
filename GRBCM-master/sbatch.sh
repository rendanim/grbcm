#!/bin/bash 



# The name of the script is myjob
#SBATCH -J GRBCM_EXPERIMENTS

# Only 0.5 hour wall-clock time will be given to this job
#SBATCH -t 02:30:00
#SBATCH --job-name= baselines
#SBATCH --output=output.out
#SBATCH --ntasks=1
#SBATCH --time=10:00
#SBATCH --partition=batch

# Number of nodes
#SBATCH --nodes=4
#SBATCH -e error_file.e

# Run the executable named run_cifar.m 
# and write the output into output.out
mpirun -np 1 matlab -nodisplay < baselines.m > 


