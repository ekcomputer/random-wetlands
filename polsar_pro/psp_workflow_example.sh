#!/bin/bash
#export PATH=$PATH:~/polsarPro/Soft/bin/data_import/
#export PATH=$PATH:~/polsarPro/Soft/bin/tools/
#export PATH=$PATH:~/polsarPro/Soft/bin/data_process_sngl/
#export PATH="$PATH:~/polsarPro/Soft/bin/bmp_process/"
echo Path:     $PATH
uavsar_header.exe \
-hf "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090_CX_01.ann" -id "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw" -od "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw" -df grd -tf "/home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/2020_01_22_16_39_42_uavsar_config.txt"

mkdir -p /att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3//C3/
echo MLC
uavsar_convert_MLC.exe \
-hf "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090_CX_01.ann" -if1 "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090HHHH_CX_01.grd" -if2 "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090HHHV_CX_01.grd" -if3 "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090HHVV_CX_01.grd" -if4 "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090HVHV_CX_01.grd" -if5 "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090HVVV_CX_01.grd" -if6 "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090VVVV_CX_01.grd" -od "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3//C3" -odf C3 -inr 24542 -inc 23480 -ofr 0 -ofc 0 -fnr 24542 -fnc 23480  -nlr 1 -nlc 1 -ssr 1 -ssc 1 -mem 8000 -errf "/home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/MemoryAllocError.txt" 

echo MASK
create_mask_valid_pixels.exe \
-id "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3//C3" -od "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3//C3" -idf C3 -ofr 0 -ofc 0 -fnr 24542 -fnc 23480

echo BMP
create_bmp_file.exe \
-mcol black -if "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3//C3/mask_valid_pixels.bin" -of "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3//C3/mask_valid_pixels.bmp" -ift float -oft real -clm "jet" -nc 23480 -ofr 0 -ofc 0 -fnr 24542 -fnc 23480 -mm 0 -min 0 -max 1 -mask "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/C3/mask_valid_pixels.bin"

echo FREEMAN
mkdir -p /att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/freeman/C3
freeman_decomposition.exe \
-id "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/C3" -od "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/freeman/C3" -iodf C3 -nwr 3 -nwc 3 -ofr 0 -ofc 0 -fnr 24542 -fnc 23480  -errf "/home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/MemoryAllocError.txt" -mask "/att/gpfsfs/briskfs01/ppl/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/C3/mask_valid_pixels.bin"

echo HEADER ENVI
envi_config_file.exe -bin /att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090_CX_01.inc -nam /att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01_V3/raw/yflatW_21508_17098_006_170916_L090_CX_01.inc.hdr -iodf 4 -fnr 24542 -fnc 23480

