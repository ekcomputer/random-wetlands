#!/bin/bash
# script to auto create dirs and run PSP processing
# modified for input to parallel function
# input is directory name (used to be runfile with directories)

	# ADDITIONAL USER INPUT
mem=12000
window=3 # moving window size for decomp

	#PATHS
#export PATH=$PATH:~/polsarPro/Soft/bin/data_import/
#export PATH=$PATH:~/polsarPro/Soft/bin/tools/
#export PATH=$PATH:~/polsarPro/Soft/bin/data_process_\\files.brown.edu\Home\ekyzivat\Documents\Training\SAR\PolSARProv5sngl/
#export PATH=$PATH:~/polsarPro/Soft/bin/bmp_process/

file_dir_input=$1 # could have ASC path or just ID

#

file_dir_tmp=${file_dir_input#/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/PROJECTED/UA/}
#echo File dir 1: $file_dir1
ID=${file_dir_tmp%_grd}
file_dir_ASC=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/PROJECTED/UA/$ID"_grd" # add in ASC prefix
file_dir=$NOBACKUP/UAVSAR/asf.alaska.edu/$ID # NOBACKUP
base=$file_dir/complex_lut
# file_inc=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/INC/UA/$ID.inc
# file_hgt=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/DEM_TIFF/UA/"$ID"_hgt.tif
# file_slope=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/SLOPE/UA/$ID.slope
# dir_mlc=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/COMPLEX/UA/"$ID"_mlc

#
if [ -e $file_dir/complex_lut/C3/Freeman_Odd.bin ] # [ # -e foo.txt] #
then 
	echo "... Already processed $ID (Freeman_Odd.bin exists)... skipping."
elif [ ! -e $base/$ID.ann ]
then
	echo "ERROR: No .ann file found in $base/"
else 
		# skipping file imports, because assumed to have happened in complex-rtc.py
		
		# PRINT FILENAMES
	printf "\nASF dir: \t\t $file_dir_ASC\n"
	printf "file_dir: \t\t $file_dir\n"
	printf "Base dir:\t\t $base\n\n"
		# READ HEADER (not essential)
	printf "\tReading header\n"
	uavsar_header.exe -hf $base/$ID.ann -id $base -od $base -df grd \
	 -tf /home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/`date +%Y-%m-%d-%H-%M-%S_uavsar_config.txt`

		#PARSE ANN FILE
	c3=$base/C3
	inr=$(grep grd_pwr.set_rows $base/$ID.ann | awk '{print $4}')
	inc=$(grep grd_pwr.set_cols $base/$ID.ann | awk '{print $4}')
	echo in rows: $inr
	echo in cols: $inc
	if=( $( find $base -name *.grd -type f | sort -n) )

		# MKDIR
	printf "\tCreating C3 dir\n"
	mkdir -p $c3

		#CONVERT MLC
	printf "\tConvert MLC\n"
	uavsar_convert_MLC.exe -hf $base/$ID.ann -if1 ${if[0]} -if2 ${if[1]} -if3 ${if[2]} -if4 ${if[3]} \
	-if5 ${if[4]} -if6 ${if[5]} \
	-od $base/C3 -odf C3 -inr $inr -inc $inc -ofr 0 -ofc 0 -fnr $inr -fnc $inc \
	-nlr 1 -nlc 1 -ssr 1 -ssc 1 -mem $mem \
	-errf "/home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/MemoryAllocError.txt" 

		# MASK PIXELS
	printf "\tMask Pixels\n"
	create_mask_valid_pixels.exe -id "$c3" -od "$c3" -idf C3 -ofr 0 -ofc 0 -fnr $inr -fnc $inc

		# MKDIR DECOMP
	printf "\tCreating Freeman dir\n"
	fre=$base/freeman/C3
	mkdir -p $fre

		# DECOMPOSITION
	printf "\tDecomposition\n"
	freeman_decomposition.exe \
	-id "$c3" -od "$fre" -iodf C3 -nwr $window -nwc $window -ofr 0 -ofc 0 -fnr $inr -fnc $inc  \
	-errf "/home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/MemoryAllocError.txt" -mask "$c3/mask_valid_pixels.bin" -mem $mem

		# BUILD envi headers # note: imaginary .bin files will have wrong data type (float instead of complex)
	printf "\tENVI Headers\n"
	bin_files=`find $base -name "*.bin"`
	for file in $bin_files; do
		#echo $file
		python /home/ekyzivat/scripts/UAVSAR-Radiometric-Calibration-fork/python/buildUAVSARhdr.py -i $base/$ID.ann -r $file -p HHHH
	done

	# other_bin_files=`find $base -name "*.inc" -o -name "*.slope" -o -name "*.hgt"`
	# for file in $other_bin_files; do
	# 	#echo $file
	# 	python /home/ekyzivat/scripts/UAVSAR-Radiometric-Calibration-fork/python/buildUAVSARhdr.py -i $base/$ID.ann -r $file
	# done

fi

