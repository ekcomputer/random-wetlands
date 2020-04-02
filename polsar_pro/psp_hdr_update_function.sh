#!/bin/bash
# script to auto create dirs and run PSP processing (only updating hdr, skipping computations)
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
base=$file_dir/raw
file_inc=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/INC/UA/$ID.inc

#

		# Check if file exists on ASC.  If not, use imported file
	printf "\n\tCHECKING IF INPUT FILES EXIST ON ASC\n"
	if [ -d $file_dir_ASC ]
	then 
		:
	else
		file_dir_ASC=$file_dir/raw
		file_inc=$file_dir/raw/$ID.inc
		printf "\tFile not found on ASC.  Using uploaded files in $file_dir.\n"
	fi
		
		# PRINT FILENAMES
	printf "\nASF dir: \t\t $file_dir_ASC\n"
	printf "file_dir: \t\t $file_dir\n"
	printf "Base dir:\t\t $base\n\n"

		# READ HEADER (not essential)
	printf "\n\tReading header\n"
	uavsar_header.exe -hf $file_dir_ASC/*.ann -id $file_dir_ASC -od $file_dir -df grd \
	 -tf /home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/`date +%Y-%m-%d-%H-%M-%S_uavsar_config.txt`

		#PARSE ANN FILE
	c3=$file_dir/C3
	inr=$(grep grd_pwr.set_rows $file_dir_ASC/*.ann | awk '{print $4}')
	inc=$(grep grd_pwr.set_cols $file_dir_ASC/*.ann | awk '{print $4}')
	echo in rows: $inr
	echo in cols: $inc
	if=( $( find $file_dir_ASC -name *.grd -type f | sort -n) )

		# MKDIR
	printf "\n\tCreating raw dir only.\n"
	#mkdir -p $c3
	mkdir -p $base
	
		# COPY INC FILE
	if [ -f $base/$ID.inc ]; then
		echo Needed to copy INC: $file_inc  ">>>>>"  $base
	fi
	cp -u $file_inc $base

		# COPY ANN FILE
	if [ -f $base/$ID.ann ]; then
		echo Needed to copy ANN: $file_dir_ASC/*.ann  ">>>>>"  $base
	fi
	cp -u $file_dir_ASC/*.ann $base
	
		# Copy HGT or SLP files?

		# BUILD envi headers # note: imaginary .bin files will have wrong data type (float instead of complex)
	printf "\n\tENVI Headers\n"
	bin_files=`find $file_dir -name "*.bin" -o -name "*.inc" -o -name "*.mlc" -o -name "*.slope" -o -name "*.hgt"`
	for file in $bin_files; do
		#echo $file
		envi_config_file.exe -bin $file -nam $file.hdr -iodf 4 -fnr $inr -fnc $inc
		editEnviHdr.sh $file_dir_ASC/*.ann $file.hdr
	done


