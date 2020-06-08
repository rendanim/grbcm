#!/bin/bash 



# The name of the script is myjob


# Only 0.5 hour wall-clock time will be given to this job
#SBATCH --job-name=gpbaselines
#SBATCH --time=15:00:00
#SBATCH --partition=batch
 
# Number of nodes
#SBATCH --nodes=1 
#SBATCH -e error_file.e
#SBATCH -o outp.o
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-type=fail         # send email if job fails
#SBATCH --mail-user=rendani.mbuvha@wits.ac.za

# Run the executable named run_cifar.m 
# and write the output into output.out
matlab -nodisplay < base_lines.m > output.out

