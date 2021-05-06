## For mosaicking:
# See pairs at data_paths/mosaic-pairs/pairs.txt

    # pairs
gdal_merge.py -o mosaics/PAD_170613_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0  PADELT_36000_17062_003_170613_L090_CX_01_Freeman-inc_cls.tif PADELT_18035_17062_004_170613_L090_CX_01_Freeman-inc_cls.tif &
gdal_merge.py -o mosaics/PAD_170908_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0  padelE_36000_17093_007_170908_L090_CX_01_Freeman-inc_cls.tif padelW_18035_17093_008_170908_L090_CX_01_Freeman-inc_cls.tif &

gdal_merge.py -o mosaics/PAD_180821_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0 padelE_36000_18047_000_180821_L090_CX_01_Freeman-inc_cls.tif padelW_18035_18047_001_180821_L090_CX_01_Freeman-inc_cls.tif &
gdal_merge.py -o mosaics/YFLATS_170916_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0 ftyuko_04707_17098_007_170916_L090_CX_01_Freeman-inc_cls.tif yflatE_21609_17098_008_170916_L090_CX_01_Freeman-inc_cls.tif yflatW_21508_17098_006_170916_L090_CX_01_Freeman-inc_cls.tif &

gdal_merge.py -o mosaics/YFLATS_170621_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0 yflats_04707_17069_010_170621_L090_CX_01_Freeman-inc_cls.tif yflats_21508_17069_009_170621_L090_CX_01_Freeman-inc_cls.tif &&
gdal_merge.py -o mosaics/YFLATS_180827_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0 ftyuko_04707_18051_008_180827_L090_CX_01_Freeman-inc_cls.tif yflatE_21609_18051_009_180827_L090_CX_01_Freeman-inc_cls.tif &&
gdal_merge.py -o mosaics/YFLATS_190914_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0 ftyuko_04707_19064_006_190914_L090_CX_01_Freeman-inc_cls.tif yflatE_21609_19064_007_190914_L090_CX_01_Freeman-inc_cls.tif &

    # singles
gdal_merge.py -o mosaics/pad_2017_18035_test.tif -co COMPRESS=LZW -n 0 -a_nodata 0  padelW_18035_17093_008_170908_L090_CX_01_Freeman-inc_cls.tif  &


## For re-projecting valid pixel mask (daring)
# mask=/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/daring_21405_17063_010_170614_L090_CX_01/complex_lut/C3/mask_valid_pixels.bin
# reproj=daring_21405_17063_010_170614_L090_CX_01_valid_mask.tif
mask=/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/daring_21405_17094_010_170909_L090_CX_01/complex_lut/C3/mask_valid_pixels.bin
reproj=daring_21405_17094_010_170909_L090_CX_01_valid_mask.tif
gdalwarp $mask $reproj -wo NUM_THREADS=ALL_CPUS --config GDAL_CACHEMAX 8000 \
-co COMPRESS=DEFLATE -co BIGTIFF=IF_SAFER -ot Byte -t_srs PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]



## For masking out Daring scenes
export GDAL_CACHEMAX=32000
id=daring_21405_17094_010_170909_L090_CX_01
id=daring_21405_17063_010_170614_L090_CX_01
# inc=/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/$id/raw/$id.inc
inc="$id"_LUT-Freeman.tif
in="$id"_LUT-Freeman_cls_no_mask.tif
out="$id"_LUT-Freeman_cls.tif
mask="$id"_valid_mask.tif

###  V1 Use with inc.bin
# gdal_calc.py -A $inc -B $in --outfile=$out --calc="(A>0.5)*B" # if I had inc band
# gdal_calc.py -A $inc -B $in --outfile=$out --NoDataValue=0 --overwrite --creation-option="COMPRESS=LZW" --creation-option="BIGTIFF=YES" --calc="(A>=0)*B" # if I only have Freeman bands
gdal_calc.py -A $inc --A_band=1 -B $in --outfile=$out --NoDataValue=0 --overwrite --creation-option="COMPRESS=LZW" --creation-option="BIGTIFF=YES" --calc="numpy.uint((A>=0)*B)" # if I only have Freeman bands

### V2 USe with mask_valid_px.bin
gdal_calc.py -A $mask --A_band=1 -B $in --outfile=$out --NoDataValue=0 --overwrite --creation-option="COMPRESS=LZW" --creation-option="BIGTIFF=YES" --calc="numpy.uint((A>0)*B)" # if I only have Freeman bands

## For compressing

## Redo mosaics in reverse: note first layer goes on BOTTOM in mosaic, last on TOP

    # pairs
gdal_merge.py -o mosaics-yf-reverse/YFLATS_170916_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0 yflatW_21508_17098_006_170916_L090_CX_01_Freeman-inc_cls.tif yflatE_21609_17098_008_170916_L090_CX_01_Freeman-inc_cls.tif ftyuko_04707_17098_007_170916_L090_CX_01_Freeman-inc_cls.tif  &&

gdal_merge.py -o mosaics-yf-reverse/YFLATS_170621_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0 yflats_21508_17069_009_170621_L090_CX_01_Freeman-inc_cls.tif yflats_04707_17069_010_170621_L090_CX_01_Freeman-inc_cls.tif  &&
gdal_merge.py -o mosaics-yf-reverse/YFLATS_180827_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0 yflatE_21609_18051_009_180827_L090_CX_01_Freeman-inc_cls.tif ftyuko_04707_18051_008_180827_L090_CX_01_Freeman-inc_cls.tif  &&
gdal_merge.py -o mosaics-yf-reverse/YFLATS_190914_cls_mosaic.tif -co COMPRESS=LZW -n 0 -a_nodata 0 yflatE_21609_19064_007_190914_L090_CX_01_Freeman-inc_cls.tif ftyuko_04707_19064_006_190914_L090_CX_01_Freeman-inc_cls.tif  &
