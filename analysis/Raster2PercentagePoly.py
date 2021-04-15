#!/home/ekyzivat/miniconda2/envs/geohack/env/python
# coding: utf-8

# Convert a land cover raster to a shapefile, with attributes for fractional class coverage
# 
# Run first (#1) in workflow to get em % for PAD lakes -> Raster2Percentage Poly -> AVerage_em.ipynb

# TODO: 
# * Add buffers to filter out disconnected littoral zones w no water nearby,
# * Size filters
# * ~~spatial join X
# * simplify polygons -or smooth
# * double check number of unique polygons ----> debug
# * ~~export to .shp X
# * save polygonization process as a function - and use parallel for rasterio polygonize/rasterize!!

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
import rasterio as rio
from rasterio import plot, features
from rasterio.features import shapes
import shapely
from shapely.geometry import shape

# Import env variables
from python_env import *

## dynamic I/O

# shape_dir=os.path.join(base_dir.split('batch')[0], 'shp') # remove any batches appended to path # for developpment
# shape_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp'# for final deployment # from python_env.py
# load using rasterio
files_in=glob.glob(base_dir+'/*cls.tif')

for i in range(len(files_in)):
    ## Option for quickly building only PAD mosaics ############
    if ('PAD' in files_in[i]) & ('mosaic' in files_in[i]):
        pass
    else:
        continue
    ############################################################

    landcover_in_path=files_in[i] # '/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls.tif'
    print(f'\n\n----------------\nInput: {landcover_in_path}')
    print(f'\t(File {i} of {len(files_in)})\n')
    poly_out_pth=os.path.join(shape_dir, os.path.splitext(os.path.basename(landcover_in_path))[0] +'_wc.shp') #'/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/shp/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls_poly.shp'
    if os.path.exists(poly_out_pth):
        print('Shapefile already exists. Skipping...')
        continue
    # segimg=glob.glob('Poly.tif')[0]
    with rio.open(landcover_in_path) as src:
        lc = src.read(1)
    lc.shape


    # In[4]:
    # load srs for area math, etc
    with rio.open(landcover_in_path) as src:
        src_crs=src.crs
        src_res=src.res
        src_shp=src.shape
        src=src
        print(src.profile)
        # rio.plot.show(src)
        # plt.draw()
        # plt.show(block = False)
    src_res


    # In[5]:

    lc.shape
    plt.imshow(lc)


    # # Burn the bridges!
    # In[6]:


    ## burn in artificial bridges to separate open-basin lakes
    bridges=gpd.read_file(bridges_pth)
    bridges.head()



    # In[7]:


    # try 3 https://gis.stackexchange.com/questions/151339/rasterize-a-shapefile-with-geopandas-or-fiona-python
    bridges['val']=bridge_val # add dummy variable
    # bridges.head()
    bridges.val
    shapes_gen = ((geom,value) for geom, value in zip(bridges.geometry, bridges.val))
    bridges_burned = features.rasterize(shapes=shapes_gen, fill=0, out_shape=src.shape, transform=src.transform, all_touched=True)


    # In[8]:


    # plt.imshow(bridges_burned)
    print(f'Number of bridge pixels burned: {(bridges_burned>0).sum()}') # sanity check


    # In[9]:
    # add burned bridges to original landcover raster
    np.sum(lc==bridge_val)
    lc[bridges_burned>0]=bridge_val
    print(f'Number of bridge pixels burned into landcover: {np.sum(lc==bridge_val)}')


    # In[10]:
    # and convert to label matrix
    lb=label(np.isin(lc, classes['wet']), connectivity=2)
    # plt.imshow(lb)
    # lb


    # In[11]:


    ## create masks
    mask_wet_emerg = np.isin(lc, classes['wet_emergent'])
    mask_wet = np.isin(lc, classes['wet'])
    print(f'Number of masked pixels: {np.sum(mask_wet)}')


    # Use rasterio of Sean Gillies. It can be easily combined with Fiona (read and write shapefiles) and shapely of the same author.
    # 
    # In the script rasterio_polygonize.py the beginning is

    # In[29]:

    ## convert to polygon #https://gis.stackexchange.com/questions/187877/how-to-polygonize-raster-to-shapely-polygons
    # from rasterio.features import shapes
    # with rio.drivers():
    image =  lb.astype('float32') # src.read(1) # first band # np.isin(lc, classes['wet_emergent']).astype('float32')
    results = (
    {'properties': {'raster_val': v}, 'geometry': s}
    for i, (s, v) 
    in enumerate(
        shapes(image, mask=mask_wet, transform=src.transform, connectivity=8))) # transform=src.affine, mask=mask
    # print('Example of geometry feature created:')
    # pprint.pprint(next(results))


    # The result is a generator of GeoJSON features

    # In[30]:


    geoms = list(results)
    print(f'Number of polygons created: {len(geoms)}')

    # In[31]:
    # That you can transform into shapely geometries
    # Create geopandas Dataframe and enable easy to use functionalities of spatial join, plotting, save as geojson, ESRI shapefile etc.
    # In[33]:
    ## convert to polygon
    poly  = gpd.GeoDataFrame.from_features(geoms,crs=src_crs.wkt)
    poly.head(20)

    # In[36]:
    poly['label']=poly['raster_val'].astype(int) # for some reason, I had to create poly using double precesion? other int types?
    del poly['raster_val']
    poly.head()

    # In[37]:
    # poly.plot()
    # plt.draw()
    # plt.show(block = False)

    # # Regionprops
    # In[38]:
    # regionprops!
    ## re-compute as table (slower bc not lazy computation)
    stats=measure.regionprops_table(lb, np.isin(lc, classes['wet_emergent']), cache=True, properties=['label','area','perimeter','mean_intensity']) # Users should remember to add "label" to keep track of region # cache is faster, but more mem identities.

    # In[41]:
    ## area math
    stats=pd.DataFrame(stats)
    stats.mean_intensity.max()
    stats['em_fraction']=stats['mean_intensity']
    del stats['mean_intensity']

    stats['area_px_m2']=stats.area*np.prod(src_res)
    stats['perimeter_px_m']=stats.perimeter*np.mean(src_res)
    del stats['area']
    del stats['perimeter']

    # In[42]:
    print(f'Label range: {lb.min()} : {lb.max()}')
    print(f'Number of polygon geometries created: {len(geoms)}')
    print(f'Number of polygons created: {len(poly)}') 

    # In[43]:


    ## test to find unique vals

    # len(poly)
    # poly.iloc[:,1].unique().shape
    # poly.shape
    poly.label.max()
    poly.label.unique().shape
    d1=np.setdiff1d(poly.label.unique(), stats.label) # > Return the unique values in `ar1` that are not in `ar2`.
    d2=np.setdiff1d(stats.label,poly.label.unique())
    print(f'Number of polygons that aren\'t listed in regionprops: {d1.size}')
    print(f'Number of regionprops regions that didn\'t become polygons: {d2.size}')
    d2


    # # Attribute join
    # In[45]:

    poly=poly.merge(stats, on='label') #country_shapes = country_shapes.merge(country_names, on='iso_a3')
    poly.head()

    # In[46]:
    ## Simplify polygons using shapely, if I wish:
    # object.simplify(tolerance, preserve_topology=True)

    # check if anything didn't merge
    print('Any polygons that didn\'t merge?')
    print(np.any(poly['em_fraction'].isnull()))

    # # save to .shp

    # In[47]:
    # poly_simpl.to_file(poly_out_pth)
    poly.to_file(poly_out_pth)
    print(f'Wrote file: {poly_out_pth}')

    # plt.show() # to keep plots?
    # # Compute and plot statistics for EM

    # In[48]:

    # plt.hist(poly[poly.area_px_m2>50][poly.em_fraction<1][poly.em_fraction>0].em_fraction)
    # plt.title('EM fraction for WBs > 50 m2 with littoral zones')
    # plt.ylabel('count')
    # plt.xlabel('EM fraction')
