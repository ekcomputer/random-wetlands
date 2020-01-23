#!/bin/bash
# Script to add georef line to ENVI header
# inputs are .ann and .hdr file name

	#PARSE
long=$(cat $1 | grep -e "grd_pwr.col_addr" | awk '{print $4}')
lat=$(cat $1 | grep -e "grd_pwr.row_addr" | awk '{print $4}')
longpx=$(cat $1 | grep -e "grd_pwr.col_mult" | awk '{print $4}')
latpx=$(cat $1 | grep -e "grd_pwr.row_mult" | awk '{print $4}') # get rid of minus sign?
echo map info = {Geographic Lat/Lon, 1, 1, $long, $lat, ${longpx#-}, ${latpx#-}, WGS-84} >> $2 # removes leading minus sign from pixel measurements

echo
echo Added georef info to header file: $2
echo
