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
	if [ -e $file_dir/C3/C11.bin ]
	then echo .bin exists
	else echo .bin DOESNT exist
	fi
		
done
printf "Done processing files.\n"

