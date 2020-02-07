#!/bin/bash
# Input one is function to run.  INput 2 is file to cat as input to function.
# Re-written to parse inputs if they start in original ASF folder or my ASF folder
# Re-written to revert to original: input is dir list in original ASF folder w no parsing
printf "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\nStarting processing files...\n"

	# no input file parsing
for file_dir in $(cat $2)
do
	bash $1 $file_dir
done
#cat $2 | parallel "bash $1 {} "

printf "Done processing files.\n"
