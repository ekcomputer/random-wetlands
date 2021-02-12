#!/bin/bash
# this script copies all necessary files for polsar pro to $NOBACKUP dir without duplicating existing files
# first arg: input file name with dirs to copy. ex: uavsar.txt
for file_dir in $(cat $1)
do
	#printf "\nDirectory: $file_dir\n"
	file_dir1=${file_dir#/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/PROJECTED/UA/}
	#echo File dir 1: $file_dir1
	ID=${file_dir1%_grd}
	file_dir_new=$NOBACKUP/UAVSAR/asf.alaska.edu/$ID/raw
	printf "\nID = $ID\n"
	file_inc=/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/INC/UA/$ID.inc
	#echo New dir: $file_dir_new
	#files=$(ls $file_dir_new/*.grd 2> /dev/null | wc -l)
	#echo $files
	#if [[ $files=6 ]]; then
		#echo No Exists: $file_dir_new/*HVVV*.grd
		echo Making dir: $file_dir_new
	mkdir -p $file_dir_new
		echo Copying GRD: $file_dir contents ">>>>>" 
	cp -u $file_dir/* $file_dir_new
		echo Copying INC: $file_inc ">>>>>>>" $file_dir_new
	cp -u $file_inc $file_dir_new
	#echo Copying : $file_inc ">>>>>>>" $file_dir_new # SLOPE and HGT

done
printf "Finished copying.\n\n"
