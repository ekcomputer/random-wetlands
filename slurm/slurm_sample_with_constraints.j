#!/bin/bash
#SBATCH --job-name=helloWParallel

#SBATCH --mem=12G
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --time-min=1:45
#SBATCH --time=5:45
#SBATCH --mail-user=ekyzivat
#SBATCH --mail-type=ALL # test
## SBATCH -D ~/slurm-logs

# test comment
## SBATCH --mem-per-cpu=2G
#  --ntasks-per-node=1
#  --cpus-per-task=1
srun -n 1 matlab -nodisplay -nosplash -nodesktop -r "run('~/scripts/random-wetlands/slurm/helloWorld.m');exit;"

