#!/bin/bash
# script to auto create dirs and run PSP processing
# input is runfile with directories

	# ADDITIONAL USER INPUT
mem=12000
window=3 # moving window size for decomp

	#PATHS
#export PATH=$PATH:~/polsarPro/Soft/bin/data_import/
#export PATH=$PATH:~/polsarPro/Soft/bin/tools/
#export PATH=$PATH:~/polsarPro/Soft/bin/data_process_sngl/
#export PATH=$PATH:~/polsarPro/Soft/bin/bmp_process/

printf "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\nStarting processing files...\n"
for file_dir in $(cat $1)
do
	base=$file_dir/raw
	printf "Base dir:\t\t $base\n"
		
		# READ HEADER (not essential)
	printf "\tReading header\n"
	uavsar_header.exe -hf $base/*.ann -id $base -od $file_dir -df grd \
	 -tf /home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/`date +%Y-%m-%d-%H-%M-%S_uavsar_config.txt`

		#PARSE ANN FILE
	c3=$file_dir/C3
	inr=$(grep grd_pwr.set_rows $file_dir/annotation_file.txt | awk '{print $4}')
	inc=$(grep grd_pwr.set_cols $file_dir/annotation_file.txt | awk '{print $4}')
	echo in rows: $inr
	echo in cols: $inc
	if=( $( find $file_dir -name *.grd -type f | sort -n) )

		# MKDIR
	printf "\tCreating C3 dir\n"
	mkdir -p $c3

		#CONVERT MLC
	printf "\tConvert MLC\n"
	uavsar_convert_MLC.exe -hf $base/*.ann -if1 ${if[0]} -if2 ${if[1]} -if3 ${if[2]} -if4 ${if[3]} \
	-if5 ${if[4]} -if6 ${if[5]} \
	-od $file_dir/C3 -odf C3 -inr $inr -inc $inc -ofr 0 -ofc 0 -fnr $inr -fnc $inc \
	-nlr 1 -nlc 1 -ssr 1 -ssc 1 -mem $mem \
	-errf "/home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/MemoryAllocError.txt" 

		# MASK PIXELS
	printf "\tMask Pixels\n"
	create_mask_valid_pixels.exe -id "$c3" -od "$c3" -idf C3 -ofr 0 -ofc 0 -fnr $inr -fnc $inc

		# MKDIR DECOMP
	printf "\tCreating Freeman dir\n"
	fre=$file_dir/freeman/C3
	mkdir -p $fre

		# DECOMPOSITION
	printf "\tDecomposition\n"
	freeman_decomposition.exe \
	-id "$c3" -od "$fre" -iodf C3 -nwr $window -nwc $window -ofr 0 -ofc 0 -fnr $inr -fnc $inc  \
	-errf "/home/ekyzivat/.polsarpro-bio_6.0.1/Tmp/MemoryAllocError.txt" -mask "$c3/mask_valid_pixels.bin" -mem $mem

		# BUILD envi headers
	printf "\tENVI Headers\n"
	bin_files=`find $file_dir -name "*.bin" -o -name "*.inc" -o -name "*.mlc" -o -name "*.slope" -o -name "*.hgt"`
	for file in $bin_files; do
		#echo $file
		envi_config_file.exe -bin $file -nam $file.hdr -iodf 4 -fnr $inr -fnc $inc
		./editEnviHdr.sh $file_dir/annotation_file.txt $file.hdr
	done
		
done
printf "Done processing files.\n"

