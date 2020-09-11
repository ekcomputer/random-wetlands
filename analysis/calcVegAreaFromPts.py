#!/usr/bin/env python
# coding: utf-8

# An automatic way of calculating littoral fraction from a shapefile of water bodies and a list of points
# 
# 

# In[1]:


#  Script to calculate total vegetated area for each water body, given pt
#  inputs of water bodies
# Inputs:           input dir containing list of classified rasters
#                   water_classes =         class numbers for water or
#                                           inundated vegetation
#                   xls_in =                spreadsheet w lake locs
#                   Buffer distance
#
#
#  Ethan Kyzivat, April 2020


# TODO: Add buffers before spatial join, fix matching crs problem...


# In[16]:


get_ipython().run_line_magic('matplotlib', 'inline')
import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import geopandas as gpd

from pandas import DataFrame
from shapely.geometry import Point

get_ipython().run_line_magic('autosave', '60')


# In[2]:


# I/O to pandas dataframe and convert to numeric
xls_in='/mnt/f/PAD2019/Chemistry/ABoVE_Lakes_all.csv'
shp_in='/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/shp/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls_poly.tif'
csv_out_pth='/mnt/f/PAD2019/Chemistry/practice/ABoVE_Lakes_all_em_fraction.csv'

df=pd.read_csv(xls_in, encoding='ISO-8859-1')
df.Latitude_dd.dtype
df.dtypes
# df.astype({'Latitude_dd': 'float64'}).dtypes
df['Latitude_dd']=df['Latitude_dd'].astype('float64')
# df.head()
# df.Latitude_dd + df.Longitude_dd
df.dtypes
# df['Longitude_dd']


# In[3]:


# convert to geopandas dataframe
geometry = [Point(xy) for xy in zip(df.Longitude_dd, df.Latitude_dd)] # https://gist.github.com/nygeog/2731427a74ed66ca0e420eaa7bcd0d2b
crs = {'init': 'epsg:4326'} #http://www.spatialreference.org/ref/epsg/2263/ # EK: need to define crs
points = gpd.GeoDataFrame(df, crs=crs, geometry=geometry)
points.plot()


# In[4]:


## load in polygons
poly_in_pth='/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/shp/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls_poly.shp'
poly=gpd.read_file(poly_in_pth)
poly=gpd.read_file(poly_in_pth) # repeating seems to allow it to load crs...weird!
poly


# In[5]:


# poly.crs='+proj=aea +lat_1=50 +lat_2=70 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs'
poly.crs


# # Buffer before spatial join

# In[8]:


## reproject points
# points1=points.to_crs(crs='PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["NAD83",DATUM["North_American_Datum_1983",SPHEROID["GRS 1980",6378137,298.2572221010042,AUTHORITY["EPSG","7019"]],AUTHORITY["EPSG","6269"]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433],AUTHORITY["EPSG","4269"]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["standard_parallel_1",50],PARAMETER["standard_parallel_2",70],PARAMETER["latitude_of_center",40],PARAMETER["longitude_of_center",-96],PARAMETER["false_easting",0],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]]]')
# points1=points.to_crs(epsg=102001)
# points1=points.to_crs({'init': 'epsg:102001'}) # test # HERE <-----------------------------
# points1=points.to_crs(crs='+proj=aea +lat_1=50 +lat_2=70 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs')
points=points.to_crs(poly.crs) # use CRS of polygons
points.crs
# dir(poly)
# type(poly)
# poly.crs={'init': 'epsg:102001'}
# poly.crs
points.crs


# In[9]:


# points['buffer_geom']=points.buffer(30) # 30 m
# To change which column is the active geometry column, use the GeoDataFrame.set_geometry() method. # https://geopandas.org/data_structures.html
buffer=15
points_buffer=points # init
points_buffer['geometry']=points.buffer(buffer, 2) # 15 m, scale of 1 creates a 6-pt circle, scale 2: 9 pts
points_buffer.plot() # why is it empty??? Becasue polygons are so small at that scale!
# points_buffer[8]
type(points_buffer)
# type(points1)
points_buffer.set_geometry('geometry')
points_buffer.head()
# points.head()
# points.iloc[1,:]
# print(points_buffer.geom[1])
# points_buffer.geometry


# # Spatial join

# In[10]:


# points_buffer.plot()
# points_buffer['geometry'][6]
points_buffer.geometry[0:2]
points_buffer.iloc[0,4]
print(points_buffer.geometry[1])


# In[11]:


## spatial join!

points_join=gpd.sjoin(points_buffer, poly, how="left", op='intersects')
points_join.head()


# In[12]:


print(f'Number of joined polygons: {(~np.isnan(points_join.label)).sum()} (buffer ={buffer})')


# # print out csv

# In[27]:


# add attiribute for filename
scene_name=os.path.basename(shp_in)[:40] #.split('_')
scene_id=scene_name.split('_')[1]
date=scene_name.split('_')[4]
print(f'Added attributes:\n\t{scene_name}\n\t{scene_id}\n\t{date}')
# print(scene_id)
# print(date)
points_join['scene_id']=scene_id
points_join['scene_name']=scene_name
points_join['date']=date
points_join.head()


# In[13]:


csv_out=pd.DataFrame(points_join.copy())
del csv_out['geometry']
csv_out.head()
# points_join.head()
csv_out.to_csv(csv_out_pth)


# # Scrap

# In[5]:


# another way that doesn't work bc only a dataframe...
gdf = gpd.read_file(xls_in)
gdf.head()


# In[15]:


# concat test
csv2=csv_out.copy()
csv_cat=pd.concat((csv_out, csv2))
csv_cat
# csv2


# In[7]:


# try without copying
# points['geom_buffer']=points.buffer(30, 2)
# points.set_geometry('geom_buffer')


# In[11]:


get_ipython().system('file /mnt/f/PAD2019/Chemistry/ABoVE_Lakes_all.csv')

