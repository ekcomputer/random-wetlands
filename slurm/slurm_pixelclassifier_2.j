#!/bin/bash
#SBATCH --job-name=PixClas2
#SBATCH --mem-per-cpu=16G
#SBATCH --cpus-per-task=8
#SBATCH --export=ALL
#SBATCH --mail-user=ekyzivat
#SBATCH --mail-type=ALL # test
# # -D ~/slurm-logs
# test comment
#  --ntasks-per-node=1
# --ntasks=8
# --time-min=1:45

srun -n 1 matlab -nodisplay -nosplash -nodesktop -r "addpath \
    /att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork \
    /att/gpfsfs/home/ekyzivat/scripts/random-wetlands; \
    run('/att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork/pixelClassifier.m'); \
    exit;"

