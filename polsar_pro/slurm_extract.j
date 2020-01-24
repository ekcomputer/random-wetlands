#!/bin/bash
#SBATCH --job-name=convert_MLC

#SBATCH --mem=64G
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --mail-user=ekyzivat
#SBATCH --mail-type=ALL # test
## SBATCH -D ~/slurm-logs
## SBATCH --mem-per-cpu=2G
#  --ntasks-per-node=1
#  --cpus-per-task=1
srun -n 1 uavsar_convert_MLC.exe -hf "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01/raw/yflatW_21508_17098_006_170916_L090_CX_01.ann" -if1 "/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01/raw/yflatW_21508_17098_006_170916_L090HHHH_CX_01.grd" -if2 "/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01/raw/yflatW_21508_17098_006_170916_L090HHHV_CX_01.grd" -if3 "/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01/raw/yflatW_21508_17098_006_170916_L090HHVV_CX_01.grd" -if4 "/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01/raw/yflatW_21508_17098_006_170916_L090HVHV_CX_01.grd" -if5 "/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01/raw/yflatW_21508_17098_006_170916_L090HVVV_CX_01.grd" -if6 "/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01/raw/yflatW_21508_17098_006_170916_L090VVVV_CX_01.grd" -od "/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01/C3" -odf C3 -inr 24519 -inc 23464 -ofr 0 -ofc 0 -fnr 24519 -fnc 23464  -nlr 1 -nlc 1 -ssr 1 -ssc 1 -mem 2000 -errf "/home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/MemoryAllocError.txt" 


