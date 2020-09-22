''' Modified from Raster2PercentagePoly.py '''
import os
import glob
import matplotlib.pyplot as plt
import numpy as np
import rasterio as rio
from rasterio import plot, features
from rasterio.features import shapes

from utils import reclassify

## TODO: 
# Import env variables
from python_env import *

## dynamic IO
os.makedirs(reclass_dir, exist_ok=True)


# load using rasterio
files_in=glob.glob(base_dir+'/*cls.tif')

for i in range(len(files_in)):
    landcover_in_path=files_in[i] # '/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls.tif'
    landcover_out_path=landcover_in_path.replace('cls.tif', 'rcls.tif').replace(base_dir, reclass_dir)
    print(f'\n\n----------------\nInput:\t{landcover_in_path}')
    print(f'Output:\t{landcover_out_path}\n')

    # load srs 
    profile = rio.open(landcover_in_path).profile.copy()
    profile.update(nodata=NODATAVALUE)

    with rio.open(landcover_in_path) as src:
        lc = src.read(1)

    # reclassify
    lc_out=reclassify(lc, classes_re)
   # lc_out=lc # temp

    # write out
    with rio.open(landcover_out_path, 'w', **profile) as dst:
        dst.write(lc_out, 1)
    print(f'Output written.')
# for loading in blocks (and add parallel), see: https://gis.stackexchange.com/questions/368874/read-and-then-write-rasterio-geotiff-file-without-loading-all-data-into-memory
