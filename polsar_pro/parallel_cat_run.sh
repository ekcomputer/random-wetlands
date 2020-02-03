#!/bin/bash
# Input one is function to run.  INput 2 is file to cat as input to function.
# Re-written to parse inputs if they start in original ASF folder or my ASF folder
# Re-written to revert to original: input is dir list in original ASF folder w no parsing
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\nStarting processing files...\n"

	# no input file parsing
cat $2 | parallel "bash $1 {} "ls

	#input file parsing
#cat $2 | sed "s+/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/PROJECTED/UA/++" | sed "s+^+$NOBACKUP/UAVSAR/asf.alaska.edu/+g" | sed 's+_grd++g' | parallel "bash $1 {} "ls

#| parallel "bash $1 {} "ls
printf "Done processing files.\n"