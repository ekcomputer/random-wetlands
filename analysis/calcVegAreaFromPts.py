#!/home/ekyzivat/miniconda2/envs/geohack/env/python
# coding: utf-8

# An automatic way of calculating littoral fraction from a shapefile of water bodies and a list of points
# Run (#2) after raster2percentagepoly.py < PYTHON not IPYNB 

#  Script to calculate total vegetated area for each water body, given pt
#  inputs of water bodies
# Inputs:            (from input dir containing list of classified rasters)
#                   water_classes =         class numbers for water or
#                                           inundated vegetation
#                   xls_in =                spreadsheet w lake locs
#                   Buffer distance
#
# TODO:
# conda install -c conda-forge tqdm
# Outputs: tall csv of lakes and EM fractions
# Ethan Kyzivat, April 2020, updated April 2021

# Run second
# TODO: 


# In[16]:
import os
import glob
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import geopandas as gpd

from pandas import DataFrame
from shapely.geometry import Point
from python_env import *

# In[2]:
# I/O to pandas dataframe and convert to numeric
buffer=15

# updated to pull from python_env
# shape_dir='/mnt/f/PAD2019/classification_training/PixelClassifier/Test39/shp' # now '/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp'# for final deployment

xls_in='/mnt/f/PAD2019/Chemistry/ABoVE_Lakes_all.csv'
csv_out_all_path='/mnt/f/PAD2019/Chemistry/em_fraction_csv/ABoVE_Lakes_all_em_fraction_v2.csv'
csv_out_indiv_base='/mnt/f/PAD2019/Chemistry/em_fraction_csv/indiv_v2' # v1

# dynamic
shapes_in=glob.glob(shape_dir+'/*.shp')
os.makedirs(csv_out_indiv_base, exist_ok=True)

# loop
for i in range(len(shapes_in)):
    shp_in_pth=shapes_in[i] #'/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/shp/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls_poly.tif'
    # print(shp_in_pth)
        # Filter only PAD sites ############################################
    # if ('PAD' in os.path.basename(shp_in_pth))==False &  ('pad' in os.path.basename(shp_in_pth))==False & ('mosaic' in os.path.basename(shp_in_pth))==False: ## TODO: check this line
    #     print('Skipping non-PAD shapefile')
    #     continue
        ####################################################################
        # Continue
    print(f'\n\n----------------\nInput: {shp_in_pth}\n')
    print(f'\t(File {i} of {len(shapes_in)})')
    csv_out_indiv_path=os.path.join(csv_out_indiv_base, os.path.splitext(os.path.basename(shp_in_pth))[0]+'.csv')
    if os.path.exists(csv_out_indiv_path):
        print('Output csv already exists. Skipping...')
        continue

    # dynamic
    r_index=os.path.basename(shp_in_pth).find('_Free')
    scene_name=os.path.basename(shp_in_pth)[:r_index] #.split('_') #HERE
    scene_id=scene_name.split('_')[1]
    date=scene_name.split('_')[4]

    df=pd.read_csv(xls_in, encoding='ISO-8859-1')
    df['Latitude_dd']=df['Latitude_dd'].astype('float64') # weird csv formatting

    # In[3]:
    # convert to geopandas dataframe
    geometry = [Point(xy) for xy in zip(df.Longitude_dd, df.Latitude_dd)] # https://gist.github.com/nygeog/2731427a74ed66ca0e420eaa7bcd0d2b
    crs = {'init': 'epsg:4326'} #http://www.spatialreference.org/ref/epsg/2263/ # EK: need to define crs
    points = gpd.GeoDataFrame(df, crs=crs, geometry=geometry)
    # points.plot()

    # In[4]:
    ## load in polygons
    poly=gpd.read_file(shp_in_pth)
    poly=gpd.read_file(shp_in_pth) # repeating seems to allow it to load crs...weird!
    poly

    # # Buffer before spatial join
    # In[8]:
    ## reproject points
    points=points.to_crs(poly.crs) # use CRS of polygons
    print(f'Points crs: {points.crs}')

    # In[9]:
    # points['buffer_geom']=points.buffer(30) # 30 m
    # To change which column is the active geometry column, use the GeoDataFrame.set_geometry() method. # https://geopandas.org/data_structures.html
    points_buffer=points.copy() # init
    points_buffer['geometry']=points.buffer(buffer, 2) # 15 m, scale of 1 creates a 6-pt circle, scale 2: 9 pts
    # points_buffer.plot() # why is it empty??? Becasue polygons are so small at that scale!
    points_buffer.set_geometry('geometry')

    # # Spatial join
    # In[10]:
    # points_buffer.plot()
    print(f'Example geometry: {points_buffer.geometry[1]}')

    # In[11]:
    ## spatial join!
    points_join=gpd.sjoin(points_buffer, poly, how="left", op='intersects')
    points_join.head()
    print(f'Number of joined polygons: {(~np.isnan(points_join.label)).sum()} (buffer ={buffer})')

    # # print out csv
    # In[27]:
    # add attiribute for filename
    print(f'Added attributes:\n\t{scene_name}\n\t{scene_id}\n\t{date}')
    points_join['scene_id']=scene_id
    points_join['scene_name']=scene_name
    points_join['date']=date
    points_join.head()

    # In[13]:
    csv_out=pd.DataFrame(points_join.copy())
    del csv_out['geometry']
    # csv_out.head()
    csv_out.to_csv(csv_out_indiv_path)
    print(f'Saved csv out: {csv_out_indiv_path}')


    # In[15]:


    # concat test
    # csv2=csv_out.copy()
    if os.path.exists(csv_out_all_path):
        csv_out_all=pd.read_csv(csv_out_all_path)
        csv_out_all=pd.concat((csv_out_all, csv_out), join='inner', copy=False)
    else:
        print('Starting from scratch. No existing all csv found.')
        csv_out_all=csv_out.copy()
        pass
    
    csv_out_all.to_csv(csv_out_all_path)
    print(f'\tSaved csv out (all, overwrite): {csv_out_all_path}')
    # csv2


    # In[7]:


    # try without copying
    # points['geom_buffer']=points.buffer(30, 2)
    # points.set_geometry('geom_buffer')

# %%
