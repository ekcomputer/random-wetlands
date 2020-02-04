#!/bin/bash
#SBATCH --job-name=coin
#SBATCH --ntasks=1
#SBATCH --export=ALL
srun -n 1 ~/scripts/random-wetlands/slurm/helloWorld.m