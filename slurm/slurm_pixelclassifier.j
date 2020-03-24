#!/bin/bash
#SBATCH --job-name=PixClas
#SBATCH --mem-per-cpu=32G
#SBATCH --cpus-per-task=8
#SBATCH --export=ALL
#SBATCH --mail-user=ekyzivat
#SBATCH --mail-type=ALL # test
# # -D ~/slurm-logs
# test comment
#  --ntasks-per-node=1
# --time-min=1:45

## Reporting  start #############################
start_time="$(date -u +%s)"
echo "  Job: $SLURM_ARRAY_JOB_ID"
echo
echo "  Started on:           " `/bin/hostname -s`
echo "  Started at:           " `/bin/date`
#################################################

## Source
source /opt/PGSCplus-2.2.2/init-gdal.sh

## Run
srun -n 1 matlab -nodisplay -nosplash -nodesktop -r "addpath \
    /att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork \
    /att/gpfsfs/home/ekyzivat/scripts/random-wetlands; \
    run('/att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork/pixelClassifier.m'); \
    exit;"

## Reporting stop ###############################

echo "  Finished at:           " `date`
end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo "  Minutes elapsed:       " $(($elapsed / 60))
echo
#################################################