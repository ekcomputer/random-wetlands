''' Modified from Raster2PercentagePoly.py. Now includes step for post-classification smoothing! '''
# from analysis.python_env import NODATAVALUE
import glob
import os

import matplotlib.pyplot as plt
import numpy as np
import rasterio as rio
from rasterio import features, plot
from rasterio.features import shapes
from skimage import filters, morphology

from python_env import *
from utils import reclassify

## dynamic IO
os.makedirs(reclass_dir, exist_ok=True)


# load using rasterio
files_in=glob.glob(base_dir + os.sep + '*cls.tif')

## print reportin
print('Class dictionary: ', classes_re)

## loop

#################################################
# for i in [0]:                     # toggle to only work on one file
for i in range(len(files_in)):      # toggle to only work on all files
#################################################

    landcover_in_path=files_in[i] # '/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls.tif'
    #################################################
    # landcover_out_path=landcover_in_path.replace('cls.tif', 'rcls.tif').replace(base_dir, reclass_dir)        # toggle for normal   
    landcover_out_path=landcover_in_path.replace('cls.tif', 'rcls.tif').replace(base_dir, reclass_dir+'_tmp')   # toggle for quick tests
    #################################################
    print(f'\n\n----------------\nInput:\t{landcover_in_path}')
    print(f'Output:\t{landcover_out_path}\n')

    if os.path.exists(landcover_out_path):
        print('Output reclass raster already exists...skipping.')
    else:
        # load srs 
        profile = rio.open(landcover_in_path).profile.copy()
        profile.update(nodata=NODATAVALUE)

        with rio.open(landcover_in_path) as src:
            lc = src.read(1)

        ## reclassify
        if 'daring' in landcover_in_path:
            print('Using different class dictionary for Daring scenes.')
            print('Class dictionary: ', classes_re_daring)
            lc_out=reclassify(lc, classes_re_daring)    # use a different class dictionary
        else:   
            lc_out=reclassify(lc, classes_re)           # otherwise, proceed normally
        # lc_out=lc # if no reclassify

        ## Classification post-processing (smoothing with majority filter)
        # selem = morphology.disk(SELEM_DIAM)
        selem = morphology.square(SELEM_DIAM)
        lc_out= filters.rank.majority(lc_out, selem, mask=lc_out != NODATAVALUE)

    # lc_out=lc # temp

        # write out
        with rio.open(landcover_out_path, 'w', **profile) as dst:
            dst.write(lc_out, 1)
        print(f'Output written.')
print('Loop finished.')

# for loading in blocks (and add parallel), see: https://gis.stackexchange.com/questions/368874/read-and-then-write-rasterio-geotiff-file-without-loading-all-data-into-memory
