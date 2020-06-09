#!/bin/bash
#SBATCH -J import # --job-name=import
#SBATCH --mem-per-cpu=32G
#SBATCH  --cpus-per-task=8
# #SBATCH -n 8
#SBATCH --export=ALL
# #SBATCH --time-min=1:45
#SBATCH --mail-user=ekyzivat
#SBATCH --mail-type=ALL # test
# # SBATCH -D ~/slurm-logs
# test comment
#  --ntasks-per-node=1
# --ntasks=8
#SBATCH -o /home/ekyzivat/slurm-logs/stdout/slurm_import.j.%J.out # -o is stdout # must use full, absolute path
#SBATCH -e /home/ekyzivat/slurm-logs/stderr/slurm_import.j.%J.err # -e is stderr


## Reporting  start #############################
start_time="$(date -u +%s)"
echo "  Job: $SLURM_ARRAY_JOB_ID"
echo
echo "  Started on:           " `/bin/hostname -s`
echo "  Started at:           " `/bin/date`
#################################################

srun -n 1 matlab -nodisplay -nosplash -nodesktop -r "addpath \
    /att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork \
    /att/gpfsfs/home/ekyzivat/scripts/random-wetlands; \
    run('/att/gpfsfs/home/ekyzivat/scripts/random-wetlands/trainingImageImport.m'); \
    exit;"

## Reporting stop ###############################
echo "  Finished at:           " `date`
end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo "  Minutes elapsed:       " $(($elapsed / 60))
echo
#################################################