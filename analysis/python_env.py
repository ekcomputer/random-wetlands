''' Environment variables used for python analysis scripts
    Notation: v2 refers to final classification in 2021.

    INSTRUCTIONS:

    Workflow:
        0. Run classification in Matlab and analysis/reclass_rasters.py
        1. analysis/Raster2PercentagePoly.py (Convert a land cover raster to a shapefile, with attributes for fractional class coverage)
        2. analysis/calcVegAreaFromPts.py (An automatic way of calculating littoral fraction from a shapefile of water bodies and a list of points)
        3. analysis/Average_em.ipynb (Averages em_fraction for each site along all available dates)

    For sensitivity figure:
        1. analysis/upscaleFromLandcover.ipynb

    Be sure to update file paths in this file before running
'''
import os

# Classes: Run 38,39,40     orig    reclass_old reclass 2021_reclass
#                 1       W1 W      10          2       2
#                 2       SW WE     9           3       4
#                 3       HW W      10          2       2
#                 4       BA W      10          2       2
#                 5       GW WE     9           3       3
#                 6       GD        4           1       1
#                 7       SD        3           1       1
#                 8       FD        1           1       1
#                 9       FD2       1           1       1
#                 10      WD        3           1       1
#                 11      W2 W      10          2       2
#                 12      BG        5           1       1
#                 13      FW WE     9           3       5

# Classes: Run 35 (Freeman-LUT, Daring)         reclass 2021_reclass (Note that Daring class schema has no BA, but TW and TD )
#                 1       W1 W                  2       2
#                 2       SW WE                 3       4
#                 3       HW W                  2       2
#                 4       TW                            3
#                 5       GW WE                 3       3
#                 6       GD                    1       1
#                 7       SD                    1       1
#                 8       FD                    1       1
#                 9       FD2                   1       1
#                 10      TD                            1
#                 11      W2 W                  2       2
#                 12      BG                    1       1
#                 13      FW WE                 3       5
#                 14      WD                            1


''' 
classes_re_old: (from Wang 2019)
    1   Forest
    3   Shrub
    4   Graminoid
    5   Sparsely vegetated
    9   Littoral
    10  Open water
    11  Urban

classes_re: 
    1   Dry land
    2   Open water
    3   Littoral

classes_re_2: 
    1   Dry land
    2   Open water
    3   Wet graminoid
    4   Wet shrubs
    5   Wet forest

'''
    # Constants
bridge_val=25
non_roi_val=35
urban_val=30
NODATAVALUE=0
SELEM_DIAM=3 # for majortiy filter
px_area=6.2772213285727885*6.277221328212732 # m2

    # Classes: run 39
classes={'wet': [1,2,3,4,5,11,13], 'wet_emergent':[2,5,13], 'water': [1,3,4,11]} # not used: water
classes_reclass={'wet': [2,3,4,5], 'wet_emergent':[3,4,5], 'water': [2], 'wet_graminoid': [3], 'wet_shrubs': [4], 'wet_forest': [5]} # not used: water
# classes_re={0:0, 1:2, 2:3, 3:2, 4:2, 5:3, 6:1, 7:1, 8:1, 9:1, 10:1, 11:2, 12:1, 13:3, urban_val:1} # classes_re: for three classes: dry, wet emergent, open water
classes_re={0:0, 1:2, 2:4, 3:2, 4:2, 5:3, 6:1, 7:1, 8:1, 9:1, 10:1, 11:2, 12:1, 13:5, urban_val:1} # 2021 classes_re_2: for five classes: dry, wet graminoid, wet shrubs, wet forest, open water
classes_re_daring={0:0, 1:2, 2:4, 3:2, 4:3, 5:3, 6:1, 7:1, 8:1, 9:4, 10:1, 11:2, 12:1, 13:3, 14:1, urban_val:1} # 2021 classes_re_2 from daring: for five classes: dry, wet graminoid, wet shrubs, wet forest, open water

# for single use case of harmonizing the 14-class run 35/ Daring classification with the 13-class schema for the rest. See analysis/reclass_rasters_daring_conversion.py for details.
classes_daring_conversion={0:0, 1:1, 2:2, 3:3, 4:5, 5:5, 6:6, 7:7, 8:8, 9:9, 10:6, 11:11, 12:12, 13:13, 14:10, urban_val:1} # conversion from run-35 Daring to main schema

# shape_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp'# for final deployment: study lakes
shape_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp_no_rivers'# for final deployment: study lakes

    # Classes: run EngramLakes
# classes={'wet': [1,3,11,2,5,13], 'wet_emergent':[2, 5,13], 'water': [1,3,11]} # not used: water
# classes_re={0:0, 1:2, 2:3,3:2,4:2,5:3,6:1,7:1,8:1,9:1,10:1,11:2,12:1,13:3,14:1, urban_val:1}

    # paths
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test42/batch1/compressed'                         # dir 1
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test42/batch1/mosaics'                          # dir 2
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test43'                                         
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test43/reclass-daring-conversion'                  # dir 3
base_dir='/mnt/d/GoogleDrive/ABoVE top level folder/Kyzivat_ORNL_DAAC_2021/lake-wetland-maps/13-classes'                  # dir 3

unique_date_files='/mnt/d/Dropbox/Matlab/ABoVE/UAVSAR/analysis/input_paths/unique_dates.txt' # text file with paths for unique acquisition date file names

## old
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test35'                                         # Classes: run 35 (Daring)
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test39/batch2'                                  # 
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/TestEngramLakes/Test35-Fr-LUT-LUT/inc-clip'  # Classes: run EngramLakes

# bridges_pth='/mnt/f/PAD2019/classification_training/PixelClassifier/Test38/bridges/bridges.shp'                     # For workflow that includes analysis/calcVegAreaFromPts.py (for individ lakes sampled)
bridges_pth='/mnt/f/PAD2019/classification_training/ROI-analysis/river_mask_arc_singlepart.shp'
roi_pth='/mnt/f/PAD2019/classification_training/ROI-analysis/ROI-analysis_albers.shp'
fig_dir='/mnt/d/pic/UAVSAR_classification'
cir_pth='/mnt/d/ArcGIS/FromMatlab/CIRLocalThreshClas/ORNL_final/WC_fused_hydroLakes/WC_fused_hydroLakes.shp'
    # Dynamic variables
reclass_dir=os.path.join(base_dir, 'reclass') #'/mnt/f/PAD2019/classification_training/PixelClassifier/Test39/reclass'

