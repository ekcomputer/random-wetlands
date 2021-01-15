''' Environment variables used for python analysis scripts'''
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
urban_val=30
NODATAVALUE=0

    # Classes: run 39
classes={'wet': [1,2,3,4,5,11,13], 'wet_emergent':[2,5,13], 'water': [1,3,4,11]} # not used: water
# classes_re={0:0, 1:2, 2:3, 3:2, 4:2, 5:3, 6:1, 7:1, 8:1, 9:1, 10:1, 11:2, 12:1, 13:3, urban_val:1} # classes_re: for three classes: dry, wet emergent, open water
classes_re={0:0, 1:2, 2:4, 3:2, 4:2, 5:3, 6:1, 7:1, 8:1, 9:4, 10:1, 11:2, 12:1, 13:3, urban_val:1} # 2021 classes_re_2: for five classes: dry, wet graminoid, wet shrubs, wet forest, open water


    # Classes: run EngramLakes
# classes={'wet': [1,3,11,2,5,13], 'wet_emergent':[2, 5,13], 'water': [1,3,11]} # not used: water
# classes_re={0:0, 1:2, 2:3,3:2,4:2,5:3,6:1,7:1,8:1,9:1,10:1,11:2,12:1,13:3,14:1, urban_val:1}

    # paths
base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test40'                                 # Classes: run 40
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test39/batch2'                                 # Classes: run 39
# base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/TestEngramLakes/Test35-Fr-LUT-LUT/inc-clip'  # Classes: run EngramLakes
bridges_pth='/mnt/f/PAD2019/classification_training/PixelClassifier/Test38/bridges/bridges.shp'

    # Dynamic variables
reclass_dir=os.path.join(base_dir, 'reclass') #'/mnt/f/PAD2019/classification_training/PixelClassifier/Test39/reclass'
