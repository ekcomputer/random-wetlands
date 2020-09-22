''' A bunch of functions for reclassify, etc.'''
import numpy as np
from warnings import warn

def reclassify(array, dict):
    ''' Reclassifies values in array, given a dict of format old:new. If there are any values in array that aren't present in dict, function issues a warning'''

    # validate values in array: check for values with no instructions and overlapping class values
    in_raster_vals_dict_non_unique=list(dict.keys())
    in_raster_vals_dict=np.unique(list(dict.keys()))
    out_raster_vals_dict=np.unique(list(dict.values()))
    in_raster_vals_array=np.unique(array)

    if np.any(np.isin(in_raster_vals_array, in_raster_vals_dict, invert=True)):
        warn('There are values in your input raster that are not listed in the reclassification dictionary! They will be set to zero.')
    
    array_reclass=np.zeros_like(array)
    for k in out_raster_vals_dict:
        old_vals=np.unique(np.array(list(dict.keys()))[np.array(list(dict.values()))==k])
        array_reclass[np.isin(array, old_vals)]=k #raster
    return array_reclass