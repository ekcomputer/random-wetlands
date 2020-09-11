#!/usr/bin/env python
# coding: utf-8

# Convert a land cover raster to a shapefile, with attributes for fractional class coverage
# 
# TODO: 
# * Add buffers to filter out disconnected littoral zones w no water nearby,
# * Size filters
# * ~~spatial join
# * simplify polygons -or smooth
# * double check number of unique polygons ----> debug
# * ~~export to .shp
# * save polygonization process as a function

# In[1]:


get_ipython().run_line_magic('matplotlib', 'inline')
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

get_ipython().run_line_magic('autosave', '60')

Classes:
                1       W1 W
                2       SW WE
                3       HW W
                4       BA W
                5       GW WE
                6       GD
                7       SD
                8       FD
                9       FD2
                10      WD
                11      W2 W
                12      BG
                13      FW WE

# In[2]:


## user inputs
# classes={'wet': [1,2,3,4,5,11,13, 4], 'wet_emergent':[2,4,5,13], 'water': [1,3,11, 4]} # not used: water
classes={'wet': [1,2,3,4,5,11,13], 'wet_emergent':[2,5,13], 'water': [1,3,4,11]} # not used: water


# In[3]:


# load using rasterio
landcover_in_path='/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls.tif'
poly_out_pth='/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/shp/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls_poly.shp'
bridges_pth='/mnt/f/PAD2019/classification_training/PixelClassifier/Test38/bridges/bridges.shp'
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
    rio.plot.show(src)
src_res


# In[5]:


# reshape - not needed

    # these are unecessary thanks to src.read(1)
# lc=np.moveaxis(lc,[1, 2], [0,1])
# lc=lc[:,:,0]
lc.shape
plt.imshow(lc)


# # Burn the bridges!

# In[6]:


## burn in artificial bridges to separate open-basin lakes
bridges=gpd.read_file(bridges_pth)
bridges.head()
# dir(bridges.geometry)
# bridges.to_dict()


# In[7]:


# try 3 https://gis.stackexchange.com/questions/151339/rasterize-a-shapefile-with-geopandas-or-fiona-python
bridges['val']=25 # add dummy variable
bridges.head()
bridges.val
shapes_gen = ((geom,value) for geom, value in zip(bridges.geometry, bridges.val))
bridges_burned = features.rasterize(shapes=shapes_gen, fill=0, out_shape=src.shape, transform=src.transform, all_touched=True)


# In[8]:


# plt.imshow(bridges_burned)
(bridges_burned>0).sum() # sanity check


# In[9]:


# add burned bridges to original landcover raster
np.sum(lc==25)
lc[bridges_burned>0]=25
np.sum(lc==25)


# In[10]:


# and convert to label matrix
lb=label(np.isin(lc, classes['wet']), connectivity=2)
plt.imshow(lb)
lb


# In[11]:


## create masks
mask_wet_emerg = np.isin(lc, classes['wet_emergent'])
mask_wet = np.isin(lc, classes['wet'])
print(f'Number of masked pixels: {np.sum(mask_wet)}')


# Use rasterio of Sean Gillies. It can be easily combined with Fiona (read and write shapefiles) and shapely of the same author.
# 
# In the script rasterio_polygonize.py the beginning is

# In[29]:


get_ipython().run_line_magic('time', '')
## convert to polygon #https://gis.stackexchange.com/questions/187877/how-to-polygonize-raster-to-shapely-polygons
import pprint
# from rasterio.features import shapes
# with rio.drivers():
image =  lb.astype('float32') # src.read(1) # first band # np.isin(lc, classes['wet_emergent']).astype('float32')
results = (
{'properties': {'raster_val': v}, 'geometry': s}
for i, (s, v) 
in enumerate(
    shapes(image, mask=mask_wet, transform=src.transform, connectivity=8))) # transform=src.affine, mask=mask
pprint.pprint(next(results))


# The result is a generator of GeoJSON features

# In[30]:


geoms = list(results)
print(f'Number of polygons created: {len(geoms)}')
# print(next(results))


# In[31]:


geoms[0]


# That you can transform into shapely geometries

# In[32]:


from shapely.geometry import shape
# shape(geoms[8]['geometry']) # outputs a box!
print(shape(geoms[7]['geometry']))
type(shape(geoms[7]['geometry']))
# print(geoms['geometry'][7:10])
# test_shape=shape(geoms['geometry'][7:10])
# type(test_shape)


# Create geopandas Dataframe and enable easy to use functionalities of spatial join, plotting, save as geojson, ESRI shapefile etc.

# In[33]:


## convert to polygon

poly  = gpd.GeoDataFrame.from_features(geoms,crs=src_crs.wkt)
poly.head(20)


# In[34]:


print(src.crs)


# In[35]:


poly.geometry[3]
poly[poly.raster_val==3.] # 3 is not there...


# In[36]:


poly['label']=poly['raster_val'].astype(int) # for some reason, I had to create poly using double precesion? other int types?
del poly['raster_val']
poly.head()


# In[37]:


poly.plot()


# # Regionprops

# In[38]:


# regionprops!
stats=measure.regionprops(lb, mask_wet_emerg, cache=True) # uses a mask of emergenet vegetation as intensity image, so mean_intensity gives percentage EV px
dir(stats[0])
stats[1001].mean_intensity


# In[39]:


## Display  regionprops calcs
pd.DataFrame(stats[100]).iloc[:,0]


# In[40]:


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

stats


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

# In[44]:


poly.head()


# In[45]:


poly=poly.merge(stats, on='label') #country_shapes = country_shapes.merge(country_names, on='iso_a3')
poly.head()


# In[46]:


# check if anything didn't merge
np.any(poly['em_fraction'].isnull())
# poly.head()
poly.crs


# # Simplify polygon - don't actually use this part

# In[127]:


# poly_series=gpd.geoseries.GeoSeries(poly)
# gpd.GeoSeries(poly)


# In[30]:


poly_simpl=poly.simplify(tolerance=3, preserve_topology=True)


# In[31]:


# poly_smooth1=poly.buffer(-2.).buffer(2.)


# In[119]:


type(poly_simpl)
# poly_simpl.plot('em_fraction', legend=True, figsize=(8,8)) # only works for geodataframe, not geoseries
poly_simpl.plot(figsize=(8,8))


# # save to .shp

# In[47]:


# poly_simpl.to_file(poly_out_pth)
poly.to_file(poly_out_pth)


# # Compute and plot statistics for EM

# In[48]:


plt.hist(poly[poly.area_px_m2>50][poly.em_fraction<1][poly.em_fraction>0].em_fraction)
plt.title('EM fraction for WBs > 50 m2 with littoral zones')
plt.ylabel('count')
plt.xlabel('EM fraction')


# # Unused scraps from trying to learn...

# In[25]:


## print example output
next(results)


# In[ ]:


with fiona.open(
        'test.shp', 'w',
        driver='Shapefile',
        crs=src.crs,
        schema={'properties': [('raster_val', 'int')],
        'geometry': 'Polygon'}) as dst:
    dst.writerecords(results)


# In[14]:


#https://gis.stackexchange.com/questions/187877/how-to-polygonize-raster-to-shapely-polygons
import fiona
from shapely.geometry import shape
import rasterio.features

mypoly=[]
for vec in rio.features.shapes(lb.astype('float32')):
    mypoly.append(shape(vec))


# In[ ]:


for vec, val in rio.features.shapes(lb.astype('float32')): # katia added val
    mypoly.append(shape(vec))


# In[130]:


# scratch, making copies
dir(bridges)
bridges1=bridges.copy()
del bridges1['Id']
next(bridges1.iteritems())
# bridges.iterrows
bridges


# In[85]:


from cartopy.feature import ShapelyFeature # https://scitools.org.uk/cartopy/docs/v0.14/matplotlib/feature_interface.html
bridges_shapely=ShapelyFeature(bridges, src_crs)
print(bridges_shapely)

# Error
from shapely import wkt
wkt.dumps(bridges)

