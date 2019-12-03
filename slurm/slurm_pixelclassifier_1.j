#!/bin/bash
#SBATCH --job-name=helloWParallel
#SBATCH --mem-per-cpu=16G
#SBATCH --ntasks=8
#SBATCH --export=ALL
#SBATCH --time-min=1:45
#SBATCH --mail-user=ekyzivat
#SBATCH --mail-type=ALL # test
# # SBATCH -D ~/slurm-logs
# test comment
#  --ntasks-per-node=1
#  --cpus-per-task=1
srun -n 1 matlab -nodisplay -nosplash -nodesktop -r "addpath \
    /att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork \
    /att/gpfsfs/home/ekyzivat/scripts/random-wetlands; \
    run('/att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork/pixelClassifier.m'); \
    exit;"

