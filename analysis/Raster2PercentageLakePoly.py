'''
Script to calculate emergent macrophyte percentage from uavsar lake/wetland map. Run instead of analysis/Raster2PercentagePoly.py. Make sure to use River mask in place of 'bridges' file.

UPDATE: perhaps just use as plotting function and for temporal tacking once shapefiles (without lakes) exist

Inputs:
    _   UAVSAR classification as shapefiles, with class codes from python_env.py
    _   ROI file of polygon areas to include in analysis. Used to extract ROI from larger flight swath
    _   River mask: a shapefile of rivers to exclude
    _   Optional: seed lakes from AirSWOT DCS/CIR dataset

Outputs:
    _   An ESRI shapefile with rows for each lake and attributes of Area, Perimeter, EM percentage, FW%, GW%  SW%, date/filename


TODO: 
* Add buffers to filter out disconnected littoral zones w no water nearby,
* Size filters
* ~~spatial join X
* simplify polygons -or smooth
* double check number of unique polygons ----> debug
* ~~export to .shp X
* save polygonization process as a function - and use parallel for rasterio polygonize/rasterize!!
* Add FM%, etc.

'''


# In[1]:

import os
import glob
import pprint
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import geopandas as gpd
from skimage.measure import label, regionprops, regionprops_table
from skimage import measure 
from skimage.morphology import binary_dilation, selem
import rasterio as rio
from rasterio import plot, features
from rasterio.features import shapes
import shapely
from shapely.geometry import shape

# Import env variables
from python_env import *

## dynamic I/O

## Option for loading all files in dir #####################
# files_in=glob.glob(base_dir+'/*cls.tif')
############################################################
with open(unique_date_files, 'r') as f:
    files_in=f.read().strip().split('\n')
## Option for only loading specific files ##################

for i in range(len(files_in)):
    ## Option for quickly building only PAD mosaics ############
    # if ('PAD' in files_in[i]) & ('mosaic' in files_in[i]):
    #     pass
    # else:
    #     continue
    ############################################################

    ## load using rasterio
    landcover_in_path=files_in[i] # '/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls.tif'
    print(f'\n\n----------------\nInput: {landcover_in_path}')
    print(f'\t(File {i} of {len(files_in)})\n')
    poly_out_pth=os.path.join(shape_dir, os.path.splitext(os.path.basename(landcover_in_path))[0] +'_lakes.shp') #'/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/shp/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls_poly.shp'
    if os.path.exists(poly_out_pth):
        print('Shapefile already exists. Skipping...')
        continue
    with rio.open(landcover_in_path) as src:
        lc = src.read(1)
    lc.shape

    ## load srs for area math, etc
    with rio.open(landcover_in_path) as src:
        src_crs=src.crs
        src_res=src.res
        src_shp=src.shape
        src=src
        print(src.profile)
        # rio.plot.show(src)
        # plt.draw()
        # plt.show(block = False)
    # src_res
    # lc.shape
    # plt.imshow(lc)

    ## burn in artificial bridges to separate open-basin lakes, then buffer to be safe
    #  (https://gis.stackexchange.com/questions/151339/rasterize-a-shapefile-with-geopandas-or-fiona-python)
    print('Rasterize and buffer rivers/bridges...')
    bridges=gpd.read_file(bridges_pth)
    bridges['val']=bridge_val # add dummy variable
    shapes_gen = ((geom,value) for geom, value in zip(bridges.geometry, bridges.val))
    bridges_burned = features.rasterize(shapes=shapes_gen, fill=0, out_shape=src.shape, transform=src.transform, all_touched=True)
    strelem = selem.disk(25)
    bridges_burned = binary_dilation(bridges_burned, selem = strelem)
    # plt.imshow(bridges_burned)
    print(f'Number of bridge pixels burned: {(bridges_burned>0).sum()}') # sanity check

    ## add burned bridges to original landcover raster
    #%%
    # np.sum(lc==bridge_val)
    lc[bridges_burned>0]=bridge_val
    print(f'Number of bridge pixels burned into landcover: {np.sum(lc==bridge_val)}')

    ## load ROI 
    roi=gpd.read_file(roi_pth)

    ## Rasterize, like bridges, to use as mask
    print('Rasterize ROI...')
    roi['val']=1 # add dummy variable
    shapes_gen = ((geom,value) for geom, value in zip(roi.geometry, roi.val))
    roi_burned = features.rasterize(shapes=shapes_gen, fill=0, out_shape=src.shape, transform=src.transform, all_touched=True)

    ## Convert water bodies to label matrix ## TODO: do regionprops first to filter out the spurious lakes before polygonizing! Set ==0
    lb=label(np.isin(lc, classes_reclass['wet']), connectivity=2)
    # plt.imshow(lb)
    
    ## create masks
    mask_wet_emerg = np.isin(lc, classes['wet_emergent'])
    mask_wet = np.isin(lc, classes_reclass['wet'])
    print(f'Number of masked pixels: {np.sum(mask_wet)}')

    ## convert to polygon #https://gis.stackexchange.com/questions/187877/how-to-polygonize-raster-to-shapely-polygons
    # from rasterio.features import shapes
    # with rio.drivers():
    print('Polygonizing...')
    image =  lb.astype('float32') # src.read(1) # first band # np.isin(lc, classes['wet_emergent']).astype('float32')
    results = (
    {'properties': {'raster_val': v}, 'geometry': s}
    for i, (s, v) 
    in enumerate(
        shapes(image, mask=(mask_wet) & (roi_burned==1), transform=src.transform, connectivity=8))) # transform=src.affine, mask=mask # Here only consider water within ROI
    # print('Example of geometry feature created:')
    # pprint.pprint(next(results))

    ## The result is a generator of GeoJSON features
    geoms = list(results)
    print(f'Number of polygons created: {len(geoms)}')

    # That you can transform into shapely geometries
    # Create geopandas Dataframe and enable easy to use functionalities of spatial join, plotting, save as geojson, ESRI shapefile etc.
    # In[33]:
    ## convert to polygon
    poly  = gpd.GeoDataFrame.from_features(geoms,crs=src_crs.wkt)
    poly.head(20)
    poly['label']=poly['raster_val'].astype(int) # for some reason, I had to create poly using double precesion? other int types?
    del poly['raster_val']
    poly.head()
    # poly.plot()
    # plt.draw()
    # plt.show(block = False)

    ## Regionprops
    stats=measure.regionprops_table(lb, np.isin(lc, classes['wet_emergent']), cache=True, properties=['label','area','perimeter','mean_intensity']) # Users should remember to add "label" to keep track of region # cache is faster, but more mem identities.

    ## area math
    stats=pd.DataFrame(stats)
    stats.mean_intensity.max()
    stats['em_fraction']=stats['mean_intensity']
    del stats['mean_intensity']

    stats['area_px_m2']=stats.area*np.prod(src_res)
    stats['perimeter_px_m']=stats.perimeter*np.mean(src_res)
    del stats['area']
    del stats['perimeter']

    print(f'Label range: {lb.min()} : {lb.max()}')
    print(f'Number of polygon geometries created: {len(geoms)}')
    print(f'Number of polygons created: {len(poly)}') 

    ## test to find unique vals
    poly.label.max()
    poly.label.unique().shape
    d1=np.setdiff1d(poly.label.unique(), stats.label) # > Return the unique values in `ar1` that are not in `ar2`.
    d2=np.setdiff1d(stats.label,poly.label.unique())
    print(f'Number of polygons that aren\'t listed in regionprops: {d1.size}')
    print(f'Number of regionprops regions that didn\'t become polygons: {d2.size}')
    d2


    ## Attribute join
    poly=poly.merge(stats, on='label') #country_shapes = country_shapes.merge(country_names, on='iso_a3')
    poly.head()

    ## Simplify polygons using shapely, if I wish:
    # object.simplify(tolerance, preserve_topology=True)

    # check if anything didn't merge
    print('Any polygons that didn\'t merge?')
    print(np.any(poly['em_fraction'].isnull()))

    ## Remote water bodies with no open water (wetlands) # TODO: test/check
    poly.drop(poly['em_fraction']==1, inplace=True)

    ## save to .shp
    # poly_simpl.to_file(poly_out_pth)
    poly.to_file(poly_out_pth)
    print(f'Wrote file: {poly_out_pth}')

    # plt.show() # to keep plots?
    # # Compute and plot statistics for EM
    # plt.hist(poly[poly.area_px_m2>50][poly.em_fraction<1][poly.em_fraction>0].em_fraction)
    # plt.title('EM fraction for WBs > 50 m2 with littoral zones')
    # plt.ylabel('count')
    # plt.xlabel('EM fraction')
