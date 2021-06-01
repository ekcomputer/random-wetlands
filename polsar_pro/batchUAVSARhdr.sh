#!/bin/bash
export PATH=$PATH:/home/ekyzivat/scripts/UAVSAR-Radiometric-Calibration-fork/python
buildUAVSARhdr="/home/ekyzivat/scripts/UAVSAR-Radiometric-Calibration-fork/python/buildUAVSARhdr.py"
for base in $1 $2 $3 $4 $5 $6
do
	python $buildUAVSARhdr -i $base/*.ann -r $base/*HHHH*.grd
	python $buildUAVSARhdr -i $base/*.ann -r $base/*HHHV*.grd
	python $buildUAVSARhdr -i $base/*.ann -r $base/*HVHV*.grd
	python $buildUAVSARhdr -i $base/*.ann -r $base/*HHVV*.grd
	python $buildUAVSARhdr -i $base/*.ann -r $base/*HVVV*.grd
	python $buildUAVSARhdr -i $base/*.ann -r $base/*VVVV*.grd
done
