''' Environment variables used for python analysis scripts
    Notation: v2 refers to final classification in 2021.

    TODO:
    * add switch for full vs sub- rois
    
    Classes: Run 35 (Freeman-LUT, Daring)         reclass 2021_reclass (Note that Daring class schema has no BA, but TW and TD )
                1       W1 W                  2       2
                2       SW WE                 3       4
                3       HW W                  2       2
                4       TW                            3
                5       GW WE                 3       3
                6       GD                    1       1
                7       SD                    1       1
                8       FD                    1       1
                9       FD2                   1       1
                10      TD                            1
                11      W2 W                  2       2
                12      BG                    1       1
                13      FW WE                 3       5
                14      WD                            1
                
classes_re: 
    1   Dry land
    2   Open water
    3   Wet graminoid
    4   Wet shrubs
    5   Wet forest
'''

    # Imports
import os

    # Constants
bridge_val=25 # rivers too
non_roi_val=35
urban_val=30
NODATAVALUE=0
SELEM_DIAM=3 # for majortiy filter
px_area=6.2772213285727885*6.277221328212732 # m2 # varies slightly b/w scenes, but good enough for area stats

    # Classes: run 39
classes={'wet': [1,2,3,4,5,11,13], 'wet_emergent':[2,5,13], 'water': [1,3,4,11]} # not used: water

    # Main list of ultimate water classes. Water_no_lake means water body was below probably 3 px, so likely a small pond, or a false positive. [water_not_valid is either edge or not-cir...TBD]
classes_reclass={'dry_land':1, 'wet': [2,3,4,5], 'wet_emergent':[3,4,5], 'water': [2], 'wet_graminoid': [3], 'wet_shrubs': [4], 'wet_forest': [5], 'water_no_lake': [42], 'wet_graminoid_no_lake': [43], 'wet_shrubs_no_lake': [44], 'wet_forest_no_lake': [45], 'wet_emergent_no_lake':[43,44,45], 'wet_non_lake': [42, 43, 44, 45], 'water_not_valid': [52]}
# classes_re={0:0, 1:2, 2:3, 3:2, 4:2, 5:3, 6:1, 7:1, 8:1, 9:1, 10:1, 11:2, 12:1, 13:3, urban_val:1} # classes_re: for three classes: dry, wet emergent, open water
classes_re={0:0, 1:2, 2:4, 3:2, 4:2, 5:3, 6:1, 7:1, 8:1, 9:1, 10:1, 11:2, 12:1, 13:5, urban_val:1} # 2021 classes_re_2: for five classes: dry, wet graminoid, wet shrubs, wet forest, open water
classes_re_daring={0:0, 1:2, 2:4, 3:2, 4:3, 5:3, 6:1, 7:1, 8:1, 9:4, 10:1, 11:2, 12:1, 13:3, 14:1, urban_val:1} # 2021 classes_re_2 from daring: for five classes: dry, wet graminoid, wet shrubs, wet forest, open water

# for single use case of harmonizing the 14-class run 35/ Daring classification with the 13-class schema for the rest. See analysis/reclass_rasters_daring_conversion.py for details.
classes_daring_conversion={0:0, 1:1, 2:2, 3:3, 4:5, 5:5, 6:6, 7:7, 8:8, 9:9, 10:6, 11:11, 12:12, 13:13, 14:10, urban_val:1} # conversion from run-35 Daring to main schema

## Regions lookup table for 'ROI-analysis_albers' # NOT TESTED
# region_lookup = {
# 'bakerc_16008_18047_005_180821_L090_CX_02_Freeman-inc_rcls': 'Baker',
# 'bakerc_16008_19059_012_190904_L090_CX_01_Freeman-inc_rcls': 'Baker',
# 'daring_21405_17063_010_170614_L090_CX_01_LUT-Freeman_rcls': 'Daring',
# 'daring_21405_17094_010_170909_L090_CX_01_LUT-Freeman_rcls': 'Daring',
# 'PAD_170613_mosaic_rcls': 'PAD',
# 'PAD_170908_mosaic_rcls': 'PAD',
# 'PAD_180821_mosaic_rcls': 'PAD',
# 'padelE_36000_19059_003_190904_L090_CX_01_Freeman-inc_rcls': 'PAD',
# 'YFLATS_170621_mosaic_rcls': 'YF',
# 'YFLATS_170916_mosaic_rcls': 'YF',
# 'YFLATS_180827_mosaic_rcls': 'YF',
# 'YFLATS_190914_mosaic_rcls': 'YF',
# }

## Regions lookup table for 'ROI-analysis_albers-sub': cropped to common ROI intersection
# NOTE: Can also use 'YF-common-late-summer' feature for YF, but need to find/replace below.
regions=['YF', 'PAD','CSD','CSB']
regions_old_names=['YFLATS', 'PAD','Daring','Baker']
region_lookup_sub_roi = {
'bakerc_16008_18047_005_180821_L090_CX_02_Freeman-inc_rcls': 'Baker',
'bakerc_16008_19059_012_190904_L090_CX_01_Freeman-inc_rcls': 'Baker',
'daring_21405_17063_010_170614_L090_CX_01_LUT-Freeman_rcls': 'Daring',
'daring_21405_17094_010_170909_L090_CX_01_LUT-Freeman_rcls': 'Daring',
'PAD_170613_mosaic_rcls': 'PAD-common-auto',
'PAD_170908_mosaic_rcls': 'PAD-common-auto',
'PAD_180821_mosaic_rcls': 'PAD-common-auto',
'padelE_36000_19059_003_190904_L090_CX_01_Freeman-inc_rcls': 'PAD-common-auto',
'YFLATS_170621_mosaic_rcls': 'YF-common',
'YFLATS_170916_mosaic_rcls': 'YF-common',
'YFLATS_180827_mosaic_rcls': 'YF-common',
'YFLATS_190914_mosaic_rcls': 'YF-common',
} 
region_lookup = {
'bakerc_16008_18047_005_180821_L090_CX_02_Freeman-inc_rcls': 'Baker',
'bakerc_16008_19059_012_190904_L090_CX_01_Freeman-inc_rcls': 'Baker',
'daring_21405_17063_010_170614_L090_CX_01_LUT-Freeman_rcls': 'Daring',
'daring_21405_17094_010_170909_L090_CX_01_LUT-Freeman_rcls': 'Daring',
'PAD_170613_mosaic_rcls': 'PAD',
'PAD_170908_mosaic_rcls': 'PAD',
'PAD_180821_mosaic_rcls': 'PAD',
'padelE_36000_19059_003_190904_L090_CX_01_Freeman-inc_rcls': 'PAD',
'YFLATS_170621_mosaic_rcls': 'YF',
'YFLATS_170916_mosaic_rcls': 'YF',
'YFLATS_180827_mosaic_rcls': 'YF',
'YFLATS_190914_mosaic_rcls': 'YF',
} #sub-roi

    # Classes: run EngramLakes
# classes={'wet': [1,3,11,2,5,13], 'wet_emergent':[2, 5,13], 'water': [1,3,11]} # not used: water
# classes_re={0:0, 1:2, 2:3,3:2,4:2,5:3,6:1,7:1,8:1,9:1,10:1,11:2,12:1,13:3,14:1, urban_val:1}

    # paths
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test42/batch1/compressed'                         # dir 1
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test42/batch1/mosaics'                          # dir 2
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test43'                                         
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test43/reclass-daring-conversion'                  # dir 3
base_dir='/mnt/d/GoogleDrive/ABoVE top level folder/Kyzivat_ORNL_DAAC_2021/lake-wetland-maps/13-classes'                  # dir 3
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test42/batch1/mosaics-yf-reverse'                  # for new yf mosaics in reverse order w cropping

# shape_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp'# for final deployment: study lakes
# shape_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp_no_rivers'# for final deployment: study lakes (uses post-class smoothing)
shape_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp_no_rivers_no_smoothing'# for final deployment: study lakes #no-smoothing [tag]

# shape_dir_common_roi='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp_no_rivers_subroi'# for final deployment: study lakes: cropped to common ROI intersection #sub-roi (uses post-class smoothing)
shape_dir_common_roi='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp_no_rivers_subroi_no_smoothing' # Test for removing majority filter/smoothing #no-smoothing [tag]

# output_raster_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/landcover_raster_burned' # for rasters with burned in bridges, decision between EM in lakes and standalone, and boundary mask pixels (uses post-class smoothing)
output_raster_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/landcover_raster_burned_no_smoothing' # for rasters with burned in bridges, decision between EM in lakes and standalone, and boundary mask pixels #no-smoothing [tag] 

# output_raster_dir_common_roi='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/landcover_raster_burned_subroi' # for rasters with burned in bridges, decision between EM in lakes and standalone, and boundary mask pixels: using ROI common to all acquisition dates. Not first output of reclassify. #sub-roi (uses post-class smoothing)
output_raster_dir_common_roi='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/landcover_raster_burned_subroi_no_smoothing' #no-smoothing [tag]

unique_date_files='/mnt/d/Dropbox/Matlab/ABoVE/UAVSAR/analysis/input_paths/unique_dates.txt' # text file with paths for unique acquisition date file names (uses post-class smoothing)
unique_date_files='/mnt/d/Dropbox/Matlab/ABoVE/UAVSAR/analysis/input_paths/unique_dates_no_smoothing.txt' #no-smoothing [tag]

## old
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test35'                                         # Classes: run 35 (Daring)
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test39/batch2'                                  # 
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/TestEngramLakes/Test35-Fr-LUT-LUT/inc-clip'  # Classes: run EngramLakes

# bridges_pth='/mnt/f/PAD2019/classification_training/PixelClassifier/Test38/bridges/bridges.shp'                     # For workflow that includes analysis/calcVegAreaFromPts.py (for individ lakes sampled)
bridges_pth='/mnt/f/PAD2019/classification_training/ROI-analysis/river_mask_arc_singlepart.shp'
roi_sub_pth='/mnt/f/PAD2019/classification_training/ROI-analysis/ROI-analysis-albers-sub.shp' # roi subregions common to all acquistion dates #sub-roi
roi_pth='/mnt/f/PAD2019/classification_training/ROI-analysis/ROI-analysis_albers.shp' # 
fig_dir='/mnt/d/pic/UAVSAR_classification'
cir_pth='/mnt/d/ArcGIS/FromMatlab/CIRLocalThreshClas/ORNL_final/WC_fused_hydroLakes/WC_fused_hydroLakes.shp'
    # Dynamic variables
# reclass_dir=os.path.join(base_dir, 'reclass') #'/mnt/f/PAD2019/classification_training/PixelClassifier/Test39/reclass' 
reclass_dir = '/mnt/d/GoogleDrive/ABoVE top level folder/Kyzivat_ORNL_DAAC_2021/lake-wetland-maps/5-classes-no-smoothing' #no-smoothing [tag]

## print unique raster vals:
# val=[]; 
# for v in classes_reclass.values(): 
#     for j in v: 
#         val.append(j)
# print('Unique vals: ')
# import numpy as np
# print(np.unique(val))