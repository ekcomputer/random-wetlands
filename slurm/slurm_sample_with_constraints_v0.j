#!/bin/bash
#SBATCH --job-name=helloWParallel
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=64G
#SBATCH --export=ALL
#SBATCH --time-min=1:45
#SBATCH --mail-user=ekyzivat
#SBATCH --mail-type=ALL # test

# test comment
srun -n 1 matlab -nodisplay -nosplash -nodesktop -r "run('~/scripts/random-wetlands/slurm/helloWorld_parallel.m');exit;"

