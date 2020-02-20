#!/bin/bash
#SBATCH --job-name=PixClas
#SBATCH --mem-per-cpu=32G
#SBATCH --cpus-per-task=8
#SBATCH --export=ALL
#SBATCH --mail-user=ekyzivat
#SBATCH --mail-type=ALL # test
#SBATCH --ntasks=1
# # -D ~/slurm-logs
# test comment
#  --ntasks-per-node=1
# --time-min=1:45

srun -n 1 matlab -nodisplay -nosplash -nodesktop -r "addpath \
    /att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork \
    /att/gpfsfs/home/ekyzivat/scripts/random-wetlands; \
    run('/att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork/pixelClassifier.m'); \
    exit;"

