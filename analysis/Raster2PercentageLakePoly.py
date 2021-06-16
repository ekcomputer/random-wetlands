'''
Script to calculate emergent macrophyte percentage from uavsar lake/wetland map. Polygonizes landcover map to lake polygons, with attributes for EM%, whether or not it is a border lake, and whether it was observed by AirSWOT CIR camera. Run instead of analysis/Raster2PercentagePoly.py. Make sure to use River mask in place of 'bridges' file.

UPDATE: perhaps just use as plotting function and for temporal tacking once shapefiles (without lakes) exist

Inputs:
    _   UAVSAR classification as shapefiles, with class codes from python_env.py
    _   ROI file of polygon areas to include in analysis. Used to extract ROI from larger flight swath
    _   River mask: a shapefile of rivers to exclude
    _   Optional: seed lakes from AirSWOT DCS/CIR dataset

Outputs:
    _   An ESRI shapefile with rows for each lake and attributes of Area, Perimeter, EM percentage, FW%, GW%  SW%, date/filename

Note:
    - search for the #sub-roi tag to toggle between full roi and sub-rois (changes input and output paths)

TODO: 
* Add buffers to filter out disconnected littoral zones w no water nearby,
* Size filters
* ~~spatial join X
* simplify polygons -or smooth
* double check number of unique polygons ----> debug X
* ~~export to .shp X
* save polygonization process as a function X
* - and use parallel for rasterio polygonize/rasterize!!
* Add FM%, etc. X
* Manually update bridges .
* Speed up (smaller) bridge buffer?
* additional noted in comments
* problem with doubled lake labels...does it matter if output looks good? X
* Use dask ndimage label instead of imlabel https://dask-image.readthedocs.io/en/latest/dask_image.ndmeasure.html#dask_image.ndmeasure.label
* Sensitivity analysis for: min water body size, DCS seed vs no, river mask vs no, edge lakes vs no, 5-class (with maj filter) vs 13 class versions, bridge buffer size
* Save output raster value for non-littoral EM**
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
from skimage.morphology import binary_dilation, selem, remove_small_holes
import rasterio as rio
from rasterio import plot, features
from rasterio.features import shapes
import shapely
from shapely.geometry import shape
import dask.array as da

##  functions
def polygonize(source, mask=None, connectivity=4, src=None): # transform=IDENTITY
        '''
        Inputs: 
            source = label matrix to be polygonized
            mask = optional mask to consider
            connectivity = 4 or 8
            src = from: 'with rio.open(landcover_in_path) as src'
            
        Based on  rasterio.features.shapes, but simplifies the strange loop notation needed. 
        Only real input it needs is 
        Referenced https://gis.stackexchange.com/questions/187877/how-to-polygonize-raster-to-shapely-polygons
        TODO: make failsafe by setting conditional clause for if src.transform DNE (previously transfrom was a keyword argument with default 'identify')
        '''

        source =  source.astype('float32') # needs float for some reason for shape index
        results = (
        {'properties': {'raster_val': v}, 'geometry': s}
        for i, (s, v) 
        in enumerate(
            shapes(source, mask=mask, transform = src.transform, connectivity = connectivity))) # transform=src.affine, mask=mask # Here only consider water within ROI
        # print('Example of geometry feature created:')
        # pprint.pprint(next(results))

        ## The result is a generator of GeoJSON features
        # That you can transform into shapely geometries
        # Create geopandas Dataframe and enable easy to use functionalities of spatial join, plotting, save as geojson, ESRI shapefile etc.
        geoms = list(results)

        ## convert to polygon
        poly  = gpd.GeoDataFrame.from_features(geoms,crs=src.crs.wkt)
        poly['raster_val']=poly['raster_val'].astype(int) # for some reason, I had to create poly using double precesion. Converting to int64 for simplicity.
        return poly
# Import env variables
from python_env import *

## dynamic I/O

############################################################
## Option for loading all files in dir #####################
# files_in=glob.glob(base_dir+'/*cls.tif')
############################################################
## Option for only loading specific files ##################
with open(unique_date_files, 'r') as f:
    files_in=f.read().strip().split('\n')
############################################################
## Testing: Option forloading specific file directly #######
# files_in=[
#     '/mnt/d/GoogleDrive/ABoVE top level folder/Kyzivat_ORNL_DAAC_2021/lake-wetland-maps/5-classes/PAD_170613_mosaic_rcls.tif',
#     '/mnt/d/GoogleDrive/ABoVE top level folder/Kyzivat_ORNL_DAAC_2021/lake-wetland-maps/5-classes/PAD_170908_mosaic_rcls.tif',
#     '/mnt/d/GoogleDrive/ABoVE top level folder/Kyzivat_ORNL_DAAC_2021/lake-wetland-maps/5-classes/PAD_180821_mosaic_rcls.tif'
#     ] # TODO: comment out for real
# files_in=['/mnt/d/GoogleDrive/ABoVE top level folder/Kyzivat_ORNL_DAAC_2021/lake-wetland-maps/5-classes/bakerc_16008_19059_012_190904_L090_CX_01_Freeman-inc_rcls.tif']

## Option for only loading specific files ##################
############################################################

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
    print(f'\t(File {i+1} of {len(files_in)})\n')
    file_basename = os.path.splitext(os.path.basename(landcover_in_path))[0]
    poly_out_pth=os.path.join(shape_dir_common_roi,  file_basename+'_lakes.shp') # Modify here if making lake polys for full or #sub-roi'/mnt/f/PAD2019/classification_training/PixelClassifier/Test35/shp/padelE_36000_19059_003_190904_L090_CX_01_LUT-Freeman_cls_poly.shp'
    ouput_raster_pth = os.path.join(output_raster_dir_common_roi, file_basename + '_brn.tif') # brn=burned #sub-roi
    if os.path.exists(ouput_raster_pth): # poly_out_pth
        print('Modified output tif already exists. Skipping...')
        continue
    if '#' in landcover_in_path: # allows me to "comment out" inputs in unique_dates.txt
        print('Manual skip.')
        continue
    
    ## load srs for area math, etc
    with rio.open(landcover_in_path) as src:
        lc = src.read(1)
        src_crs=src.crs
        src_res=src.res
        src_shp=src.shape
        src=src
        print(src.profile)
        profile = src.profile.copy() # save for output raster
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
    bridges_burned = features.rasterize(shapes=shapes_gen, fill=0, out_shape=src.shape, transform=src.transform, all_touched=True).astype('bool')
    strelem = selem.disk(12) #25
    bridges_burned = binary_dilation(bridges_burned, selem = strelem) # TODO: temp
    # plt.imshow(bridges_burned)
    print(f'Number of bridge pixels burned: {(bridges_burned>0).sum()}') # sanity check

    ## add burned bridges to original landcover raster
    # np.sum(lc==bridge_val)
    lc[bridges_burned>0]=bridge_val
    del bridges, bridges_burned
    print(f'Number of bridge pixels burned into landcover: {np.sum(lc==bridge_val)}')

    ## load ROI, and filter to correct feature in shapefile Corresponding to current region
    roi=gpd.read_file(roi_pth)
    roi = roi[roi.Region == region_lookup[file_basename]]
    if len(roi) == 0:
        raise ValueError('EK: Region name note found in lookup table.')

    ## Rasterize, like bridges, to use as mask
    print('Rasterize ROI...')
    roi['val']=1 # add dummy variable
    shapes_gen = ((geom,value) for geom, value in zip(roi.geometry, roi.val))
    roi_burned = features.rasterize(shapes=shapes_gen, fill=0, out_shape=src.shape, transform=src.transform, all_touched=True).astype('bool')
    lc[(roi_burned==0) & (lc != 0)]=non_roi_val # mark values that are within footprint, but not ROI as 'non_roi_val'
    del shapes_gen, roi_burned

    ## create masks
    # mask_wet_emerg = np.isin(lc, classes_reclass['wet_emergent'])
    mask_wet = np.isin(lc, classes_reclass['wet'])
    print(f'Number of masked pixels: {np.sum(mask_wet)}')

    ## Convert water bodies to label matrix
    print('Label...')
    lb=label(mask_wet, connectivity=2).astype('int32') # save memory
    print(f'Label range, before masking: {lb.min()} : {lb.max()}')
    # plt.imshow(lb)
    
    ## Regionprops
    print('Regionprops #1...')
    stats=measure.regionprops_table(lb, np.isin(lc, classes_reclass['wet_emergent']), cache=False, properties=['label','area','perimeter','mean_intensity']) # Users should remember to add "label" to keep track of region # cache is faster, but more mem identities.
    
    ## convert to DataFrame and drop entries with no open water
    stats=pd.DataFrame(stats)
    # wetland_regions=stats[stats['mean_intensity']==1.].label.to_numpy() # save labels for regions with no open water
    stats_mask_neg=(stats['mean_intensity']==1.) | (stats['area']<3) # rows not to keep (no water or less than 3 px )
    
    ## dask computation
    print('Converting to dask array and masking out wetlands and smallest ponds...')
    lbd=da.from_array(lb)
    labels_to_remove = stats[stats_mask_neg].label.to_numpy(dtype='int32')
    labels_to_remove_image_mask = da.map_blocks(np.isin, lbd, labels_to_remove, dtype='int32')
    labels_to_remove_image_mask=np.array(labels_to_remove_image_mask)
    lb[labels_to_remove_image_mask]=0 
    del labels_to_remove

    ## save values of em types that aren't lake littoral zones in modified landcover (lc) raster
    # from utils import reclassify
    lc[np.isin(lc, classes_reclass['wet_graminoid']) & labels_to_remove_image_mask] = classes_reclass['wet_graminoid_no_lake']
    lc[np.isin(lc, classes_reclass['wet_shrubs']) & labels_to_remove_image_mask] = classes_reclass['wet_shrubs_no_lake']
    lc[np.isin(lc, classes_reclass['wet_forest']) & labels_to_remove_image_mask] = classes_reclass['wet_forest_no_lake']
    lc[np.isin(lc, classes_reclass['water']) & labels_to_remove_image_mask] = classes_reclass['water_no_lake']
    del labels_to_remove_image_mask
    # lb[np.isin(lb, stats[stats_mask_neg].label.to_numpy())]=0 # remove regions from label matrix with mask criteria ## fails for large data size
    ## end rewrite

    ## Save landcover raster after modification
    with rio.open(ouput_raster_pth, 'w', **profile) as dst:
        dst.write(lc, 1)
    print(f'Wrote output raster: {ouput_raster_pth}')
    # continue # if no need to make shapefiles, quit loop here

    stats=stats[~stats_mask_neg] # update stats dataframe with the same mask
    stats.rename(columns={'mean_intensity':'em_fraction', 'area':'area_px_m2', 'perimeter':'perimeter_px_m'}, inplace=True)
    # stats['em_fraction']=stats['mean_intensity']
    # del stats['mean_intensity']

    ## area math
    stats['area_px_m2']=stats.area_px_m2*np.prod(src_res)
    stats['perimeter_px_m']=stats.perimeter_px_m*np.mean(src_res)
    # del stats['area'] 
    # del stats['perimeter']

    ## Regionprops for Fw, SW, GW
    print('Regionprops #2...') # cache or no cache? 
    stats_fw=measure.regionprops_table(lb, np.isin(lc, classes_reclass['wet_forest']), cache=True, properties=['label','mean_intensity']) # Users should remember to add "label" to keep track of region # cache is faster, but more mem identities.
    stats_fw=pd.DataFrame(stats_fw)
    # stats_fw['fw_fraction']=stats_fw['mean_intensity']
    stats_fw.rename(columns={'mean_intensity':'fw_fraction'}, inplace=True)
    # del stats_fw['mean_intensity']
    stats = stats.merge(stats_fw, on='label', how='left', validate='one_to_one')
    del stats_fw
    
    print('Regionprops #3...')
    stats_sw=pd.DataFrame(measure.regionprops_table(lb, np.isin(lc, classes_reclass['wet_shrubs']), cache=True, properties=['label','mean_intensity'])) # Users should remember to add "label" to keep track of region # cache is faster, but more mem identities.
    # stats_sw['fw_fraction']=stats_sw['mean_intensity']
    # del stats_sw['mean_intensity']
    stats_sw.rename(columns={'mean_intensity':'sw_fraction'}, inplace=True)
    stats = stats.merge(stats_sw, on='label', how='left', validate='one_to_one')
    del stats_sw

    print('Regionprops #4...')
    stats_gw=pd.DataFrame(measure.regionprops_table(lb, np.isin(lc, classes_reclass['wet_graminoid']), cache=True, properties=['label','mean_intensity'])) # Users should remember to add "label" to keep track of region # cache is faster, but more mem identities.
    # stats_gw['fw_fraction']=stats_gw['mean_intensity']
    # del stats_gw['mean_intensity']
    stats_gw.rename(columns={'mean_intensity':'gw_fraction'}, inplace=True)
    stats = stats.merge(stats_gw, on='label', how='left', validate='one_to_one')
    del stats_gw
    
    ## Mark edge lakes before deleting input objects
    print('Marking edge lakes...')
    strelem = selem.disk(1)
    nodata_mask_neg=np.isin(lc, [0, non_roi_val])
    nodata_mask_neg_no_islands = ~(remove_small_holes(~nodata_mask_neg, 30000)) # only consider outer boundary
    edge_ring = (binary_dilation(nodata_mask_neg_no_islands, selem = strelem)) & ~nodata_mask_neg_no_islands
    edge_regions = np.unique(lb[edge_ring])
    df_edge_regions = pd.DataFrame(edge_regions, columns=['label']); df_edge_regions['edge']=True
    stats = stats.merge(df_edge_regions, on='label', how='left'); stats.loc[:, 'edge'].fillna(False, inplace=True)
    del nodata_mask_neg, nodata_mask_neg_no_islands, lc

    ## convert lancover data coverage to shape
    # print('Polygonize domain...')
    # domain=polygonize(~nodata_mask_neg, mask=~nodata_mask_neg, src=src, connectivity=8) # this is a little risky if I ever update class values...but not planning on it!
    # domain = domain.dissolve(by='raster_val') # domain is all the positive data mask
    
    ## Rasterize, cir lakes
    print('Rasterize CIR lakes...')
    cir_lakes=gpd.read_file(cir_pth)
    cir_lakes['val']=1 # add dummy variable
    shapes_gen = ((geom,value) for geom, value in zip(cir_lakes.geometry, cir_lakes.val))
    cir_lakes_mask_positive = features.rasterize(shapes=shapes_gen, fill=0, out_shape=src.shape, transform=src.transform, all_touched=True).astype('bool')
    del shapes_gen

    ## Mark lakes observed by DCS/CIR
    print('Marking CIR-observed lakes...')
    cir_lakes_labels = np.unique(lb[cir_lakes_mask_positive])
    df_cir_lakes_labels = pd.DataFrame(cir_lakes_labels, columns=['label']); df_cir_lakes_labels['cir_observed']=True
    stats = stats.merge(df_cir_lakes_labels, on='label', how='left'); stats.loc[:, 'cir_observed'].fillna(False, inplace=True)

    ## convert to polygon 
    # from rasterio.features import shapes
    # with rio.drivers():
    print('Polygonizing...')
    poly=polygonize(lb, mask = mask_wet, src=src, connectivity=8)
    del lb # save memory
    
    # print(f'Number of polygon geometries created: {len(geoms)}')
    poly.rename(columns={'raster_val':'label'}, inplace=True)
    print(f'Number of polygons created: {len(poly)}') 
    poly.head()
    # poly.plot()
    # plt.draw()
    # plt.show(block = False)

    ## test to find unique vals
    print('Max polygon label: ', poly.label.max())
    # poly.label.unique().shape
    d1=np.setdiff1d(poly.label, stats.label) # > Return the unique values in `ar1` that are not in `ar2`.
    d2=np.setdiff1d(stats.label,poly.label)
    print(f'Number of polygons that aren\'t listed in regionprops: {d1.size}')
    print(f'Number of regionprops regions that didn\'t become polygons: {d2.size}')

    ## Attribute join
    poly=poly.merge(stats, on='label') #country_shapes = country_shapes.merge(country_names, on='iso_a3') # note poly has some repeating labels... validate='one_to_one'
    # poly.head()

    ## Simplify polygons using shapely, if I wish:
    # object.simplify(tolerance, preserve_topology=True)

    ## check if anything didn't merge
    # testing poly2=gpd.read_file('/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp_no_rivers/bakerc_16008_18047_005_180821_L090_CX_02_Freeman-inc_rcls_lakes.shp')
    print(f'Any polygons that didn\'t merge? {np.any(poly.em_fraction.isnull())}')

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
