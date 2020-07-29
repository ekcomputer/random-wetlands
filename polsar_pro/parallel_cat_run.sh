#!/bin/bash
# Input one is function to run.  INput 2 is file to cat as input to function.Input 3 is no of cores
# Re-written to parse inputs if they start in original ASF folder or my ASF folder
# Re-written to revert to original: input is dir list in original ASF folder w no parsing
# TODO parse -P as input
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\nStarting processing files...\n"

	# no input file parsing
cat $2 | parallel -k -P $3 "echo ~~~~~~~~~~~~~~~~~~~~~~~~~~; bash $1 {} " # the -k is really important bc it preserves output order

	#input file parsing
#cat $2 | sed "s+/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/PROJECTED/UA/++" | sed "s+^+$NOBACKUP/UAVSAR/asf.alaska.edu/+g" | sed 's+_grd++g' | parallel "bash $1 {} "ls

#| parallel "bash $1 {} "ls
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\nDone processing files.\n"
