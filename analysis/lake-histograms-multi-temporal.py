# plotting
'''
0. For PAD and YF: choose inner ROI
1. Seed with CIR maks lakes (to help YF)
1.5. Filter out edge lakes and small lakes
2. "Spatial bootstrapping"
3. Histograms of EM% and EM% binned by AREA
4. Choose best dates (in notebook) or multi-temporal hist

TODO: 
    * Dateparser for dates in filename
    * Why no effect of min size?
'''

## imports
import glob
import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import geopandas as gpd
from python_env import *

## User vars
min_size=200 # meters squared
regions=['Daring','Baker','PAD','YFLATS']

## constants
colors=['b','g','r', 'c'] # for date order
labels=dict(zip(
    [
    'daring_21405_17063_010_170614_L090_CX_01_LUT-Freeman_rcls_lakes.shp',
    'daring_21405_17094_010_170909_L090_CX_01_LUT-Freeman_rcls_lakes.shp',
    'bakerc_16008_18047_005_180821_L090_CX_02_Freeman-inc_rcls_lakes.shp',
    'bakerc_16008_19059_012_190904_L090_CX_01_Freeman-inc_rcls_lakes.shp',
    'PAD_170613_mosaic_rcls_lakes.shp',
    'PAD_170908_mosaic_rcls_lakes.shp',
    'PAD_180821_mosaic_rcls_lakes.shp',
    'padelE_36000_19059_003_190904_L090_CX_01_Freeman-inc_rcls_lakes.shp',
    'YFLATS_170621_mosaic_rcls_lakes.shp',
    'YFLATS_170916_mosaic_rcls_lakes.shp',
    'YFLATS_180827_mosaic_rcls_lakes.shp',
    'YFLATS_190914_mosaic_rcls_lakes.shp'
    ],

    [
    'Daring June 2017',
    'Daring Sept 2017',
    'Baker Aug 2018',
    'Baker Sept 2019',
    'PAD June 2017',
    'PAD September 2017',
    'PAD Aug 2018',
    'PAD Sept 2019',
    'YFLATS June 2017',
    'YFLATS Sept 2017',
    'YFLATS Aug 2018',
    'YFLATS Sept 2019'
    ]
))
## load data
####################################################
## Branch for entire directory #####################
files_in=glob.glob(os.path.join(shape_dir, '*.shp'))
# files_in=glob.glob(os.path.join(shape_dir, 'bakerc*.shp'))

####################################################
## Branch for testing ##############################
# files_in=['/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp_no_rivers/DCS-seed/PAD_170908_mosaic_rcls_lakes.shp']
####################################################

## Plotting params
# plt.rcParams
# plt.style.use('seaborn')
plt.style.use('/mnt/d/Dropbox/Python/Matplotlib-rcParams/presentation.mplstyle')

## loop
for region in regions:
    lakes_list=[]
    lakes_labels=[]
    for i, filename in enumerate(files_in):

        ## dynamic I/O
        label = labels[os.path.basename(filename)]

        ## validate region
        if label.split(' ')[0] != region:
            continue

        print('label: '+label)

        ## print
        print(f'\n\n----------------\nInput: {filename}')
        print(f'\t(File {i+1} of {len(files_in)})\n')

        ## I/O
        lakes = gpd.read_file(filename)

        ## filter
        filter=(lakes.edge==False) & (lakes.area_px_m2>=min_size/px_area) & (lakes.cir_observ==True)

        ## plot
        # plt.hist(lakes[filter].em_fractio)#, bins=40)
        # plt.title(f'EM fraction for lakes > {min_size} m2 ({min_size/px_area:.0f} px)')
        # plt.ylabel('Lake count')
        # plt.xlabel('Emergent macrophyte fraction')
        # plt.show()

        ## save data to memory
        lakes_list.append(lakes[filter])
        lakes_labels.append(label)

    ## Multi-termporal plot
    # fig, ax = plt.subplots()
    for i, lakes in enumerate(lakes_list):
        plt.hist(lakes.em_fractio, alpha=0.4, color=colors[i], label=lakes_labels[i])
    # ax.legend()
    # fig.show()
    plt.ylabel('Lake count')
    plt.xlabel('Emergent macrophyte fraction')
    plt.title(f'Lakes > {min_size} m2 ({min_size/px_area:.0f} px)')
    plt.legend()

    ## save fig
    figname=os.path.join(fig_dir, 'Hists-time-'+region)
    plt.savefig(figname + '.jpg', dpi=300)
    plt.savefig(figname + '.pdf', dpi=300)
    plt.show()
    pass # for breakpoint