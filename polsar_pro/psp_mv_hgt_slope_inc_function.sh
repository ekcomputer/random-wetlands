#!/bin/bash
# script to auto move height and slope and inc files... in progress...
# modified for input to parallel function
# input is directory name (used to be runfile with directories)
# TODO : add grd cp if necessary

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
base=$file_dir/raw
file_inc=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/INC/UA/$ID.inc
file_hgt=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/DEM_TIFF/UA/"$ID"_hgt.tif
file_slope=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/SLOPE/UA/$ID.slope
dir_mlc=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/COMPLEX/UA/"$ID"_mlc
dir_grd_orig=$file_dir/default_grd
#

		# Check if file exists on ASC.  If not, use imported file
	printf "\n\tCHECKING IF INPUT FILES EXIST ON ASC\n"
	if [ -d $file_dir_ASC ]
	then 
		:
	else
		file_dir_ASC=$file_dir/raw
		file_inc=$file_dir/raw/$ID.inc
		file_hgt=$file_dir/raw/$ID_hgt.tif
		file_slope=$file_dir/raw/$ID.slope
		printf "\tFile not found on ASC.  Using uploaded files in $file_dir.\n"
	fi
		
		# PRINT FILENAMES
	printf "\nASF dir: \t\t $file_dir_ASC\n"
	printf "file_dir: \t\t $file_dir\n"
	printf "Base dir:\t\t $base\n\n"

		# READ HEADER (not essential)
#	printf "\n\tReading header\n"
#	uavsar_header.exe -hf $file_dir_ASC/*.ann -id $file_dir_ASC -od $file_dir -df grd \
#	 -tf /home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/`date +%Y-%m-%d-%H-%M-%S_uavsar_config.txt`

		#PARSE ANN FILE
	c3=$file_dir/C3
#	inr=$(grep grd_pwr.set_rows $file_dir_ASC/*.ann | awk '{print $4}')
#	inc=$(grep grd_pwr.set_cols $file_dir_ASC/*.ann | awk '{print $4}')
#	echo in rows: $inr
#	echo in cols: $inc
#	if=( $( find $file_dir_ASC -name *.grd -type f | sort -n) )

		# MKDIR
	printf "\n\tCreating raw dir only.\n"
	#mkdir -p $c3
	mkdir -p $base
	mkdir -p $dir_grd_orig
	
		# COPY GRD FILE
	if [ ! -f $base/*HHHV*.grd ]; then
		echo Needed to copy GRD: $file_dir_ASC/*  ">>>>>"  $dir_grd_orig
	fi
	cp -u $file_dir_ASC/* $dir_grd_orig	
	
		# COPY INC FILE
	if [ ! -f $base/$ID.inc ]; then
		echo Needed to copy INC: $file_inc  ">>>>>"  $base
	fi
	cp -u $file_inc $base

		# COPY ANN FILE
	if [ ! -f $base/$ID.ann ]; then
		echo Needed to copy ANN: $file_dir_ASC/*.ann  ">>>>>"  $base
	fi
	cp -u $file_dir_ASC/*.ann $base
	
		# Copy HGT 
	if [ ! -f $base/"$ID"_hgt.tif ]; then
		echo Needed to copy HGT: $file_hgt  ">>>>>"  $base
	fi
	cp -u $file_hgt $base

		# Copy SLOPE
	if [ ! -f $base/"$ID".slope ]; then
		echo Needed to copy SLOPE: $file_slope  ">>>>>"  $base
	fi
	cp -u $file_slope $base

		# Copy MLC
	if [ ! -f $base/*.slc ]; then
		echo Needed to copy MLC: $dir_mlc/  ">>>>>"  $base
	fi
	cp -u $dir_mlc/*.mlc $base

		# BUILD envi headers # note: imaginary .bin files will have wrong data type (float instead of complex)
	printf "\n\tENVI Headers\n"
	bin_files=`find $file_dir -name "*.bin"`
	for file in $bin_files; do # for real/imag files
		#echo $file
#		envi_config_file.exe -bin $file -nam $file.hdr -iodf 4 -fnr $inr -fnc $inc
#		editEnviHdr.sh $file_dir_ASC/*.ann $file.hdr
		python /home/ekyzivat/scripts/UAVSAR-Radiometric-Calibration-fork/python/buildUAVSARhdr.py -i $base/$ID.ann -r $file -p HHHH
	done

		# Repeat for non-bin files (exactly the same...)
	bin_files=`find $file_dir -name "*.inc" -o -name "*.slope" -o -name "*.hgt"`	
	for file in $bin_files; do # repeat for real files
		python /home/ekyzivat/scripts/UAVSAR-Radiometric-Calibration-fork/python/buildUAVSARhdr.py -i $base/$ID.ann -r $file -p HHHH
	done


