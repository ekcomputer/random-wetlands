#!/bin/bash
#SBATCH --job-name=import_PC
#SBATCH --mem-per-cpu=32G
#SBATCH  --cpus-per-task=4
#SBATCH --export=ALL
# #SBATCH --time-min=1:45
#SBATCH --mail-user=ekyzivat
#SBATCH --mail-type=ALL # test
# # SBATCH -D ~/slurm-logs
# test comment
#  --ntasks-per-node=1
# #SBATCH --ntasks=8
srun -n 1 matlab -nodisplay -nosplash -nodesktop -r "addpath \
    /att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork \
    /att/gpfsfs/home/ekyzivat/scripts/random-wetlands; \
    run('/att/gpfsfs/home/ekyzivat/scripts/random-wetlands/trainingImageImport.m'); \
    run('/att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork/pixelClassifier.m'); \
    exit;"

