''' Environment variables used for python analysis scripts'''
# Classes: Run 38,29        orig    reclass_old reclass
#                 1       W1 W      10          2
#                 2       SW WE     9           3
#                 3       HW W      10          2
#                 4       BA W      10          2
#                 5       GW WE     9           3
#                 6       GD        4           1
#                 7       SD        3           1
#                 8       FD        1           1
#                 9       FD2       1           1
#                 10      WD        3           1
#                 11      W2 W      10          2
#                 12      BG        5           1
#                 13      FW WE     9           3


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


'''

classes={'wet': [1,2,3,4,5,11,13], 'wet_emergent':[2,5,13], 'water': [1,3,4,11]} # not used: water
bridge_val=25
urban_val=30
classes_re={0:0, 1:2, 2:3, 3:2, 4:2, 5:3, 6:1, 7:1, 8:1, 9:1, 10:1, 11:2, 12:1, 13:3, urban_val:1}
base_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test39/batch2'
bridges_pth='/mnt/f/PAD2019/classification_training/PixelClassifier/Test38/bridges/bridges.shp'
reclass_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test39/reclass'
NODATAVALUE=0