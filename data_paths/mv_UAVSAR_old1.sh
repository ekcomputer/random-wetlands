#!/bin/bash
# first arg: input file name with dirs to copy. ex: uavsar.txt
for file_dir in $(cat $1)
do
	printf "\nDirectory: $file_dir\n"
	file_dir1=${file_dir#/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/PROJECTED/UA/}
	echo File dir 1: $file_dir1
	file_dir_new=$NOBACKUP/UAVSAR/asf.alaska.edu/${file_dir1%_grd}/raw
	echo New dir: $file_dir_new
	files=$(ls $file_dir_new/*.grd 2> /dev/null | wc -l)
	echo $files
	if [[ $files=6 ]]; then
		echo No Exists: $file_dir_new/*HVVV*.grd
		echo Making dir: $file_dir_new
		echo Copying: $file_dir ">>>>>" $file_dir_new
	else
		echo GRD files already exist in: $file_dir_new
	fi
done
