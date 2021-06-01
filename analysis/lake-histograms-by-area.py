# plotting
'''
Makes a 4-panel plot from my chosen best dates for histogram, or hist by area.

0.      For PAD and YF: choose inner ROI
0.5.    Choose best dates (in notebook) or multi-temporal hist
1.      Seed with CIR maks lakes (to help YF)
3.      Histograms of EM% binned by AREA


TODO: 
    * Dateparser for dates in filename
    * Re-compute perim?
    * Spatial bootstrapping
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
min_size=500 # meters squared
regions=['Daring','Baker','PAD','YFLATS']

## constants
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
best_dates=[
    'YFLATS_180827_mosaic_rcls_lakes.shp', 'padelE_36000_19059_003_190904_L090_CX_01_Freeman-inc_rcls_lakes.shp', 'daring_21405_17094_010_170909_L090_CX_01_LUT-Freeman_rcls_lakes.shp', 'bakerc_16008_18047_005_180821_L090_CX_02_Freeman-inc_rcls_lakes.shp'
            ]
## load data
####################################################
## Branch for entire directory #####################
# files_in=glob.glob(os.path.join(shape_dir, '*.shp'))
# files_in=glob.glob(os.path.join(shape_dir, 'bakerc*.shp'))

####################################################
## Branch for testing ##############################
# files_in=['/mnt/f/PAD2019/classification_training/PixelClassifier/Final-ORNL-DAAC/shp_no_rivers/DCS-seed/PAD_170908_mosaic_rcls_lakes.shp']
####################################################

## Plotting params
# plt.rcParams
# plt.style.use('seaborn')
plt.style.use('/mnt/d/Dropbox/Python/Matplotlib-rcParams/presentation.mplstyle')
# plt.ion()

## loop
fig, ax = plt.subplots(2,2, sharex=True, figsize=(12,12), constrained_layout=True) # constrained_layout is now default for presentation
fig2, ax2 = plt.subplots(2,2, sharex=True, figsize=(12,12), constrained_layout=True) # constrained_layout is now default for presentation
fig3, ax3 = plt.subplots(2,2, sharex=True, figsize=(12,12), constrained_layout=True) # constrained_layout is now default for presentation

for i, basename in enumerate(best_dates):
    ## dynamic I/O
    filename = os.path.join(shape_dir, basename)
    label = labels[basename]
    print('label: '+label)

    ## print
    print(f'\n\n----------------\nInput: {filename}')
    print(f'\t(File {i+1} of {len(best_dates)})\n')

    ## I/O
    lakes = gpd.read_file(filename)

    ## filter
    filter=(lakes.edge==False) & (lakes.area_px_m2>=min_size) & (lakes.cir_observ==True)

    ## Fig 1: EM hist plot
    axi = np.take(ax, i)
    axi.hist(lakes[filter].em_fractio, alpha=0.4, color='b', label=label, bins=25)
    # axi.legend()
    axi.set_ylabel('Lake count')
    axi.set_xlabel('Emergent macrophyte fraction')
    axi.set_title(f'{label}\nLakes > {min_size} m2 ({min_size/px_area:.0f} px)', fontsize=16)

    ## set area bins
    nbins=25
    max_area_to_plot=5 # km2
    bins=np.linspace(0, max_area_to_plot, nbins)
    nMajorTicks=6

    ## Fig 2: Hist plot by area
    axi = np.take(ax2, i)
    area_bins=pd.cut(lakes[filter].area_px_m2/1e6, bins)
    groups=lakes[filter].groupby(area_bins)
    groups.mean().em_fractio.plot.bar(ax=axi, width=1, color='c')
    axi.set_xlabel('Area ($km^2$)')
    axi.set_ylabel('Mean emergent macrophyte fraction')
    axi.set_title(f'{label}', fontsize=16)
    # axi.set_xticks(np.arange(0,7,1))
    # axi.set_xticks(axi.get_xticks()[0:nbins+6:nbins//6])
    # axi.set_xticks(np.arange(0,7,1))
    # axi.set_xticklabels([f'{i:.1f}' for i in bins[0:nbins+6:nbins//6]], rotation = 0) # match default histogram formatting
    axi.set_xticks(np.arange(0,nMajorTicks,1)/nMajorTicks*25)
    axi.set_xticklabels(np.arange(0,nMajorTicks,1), rotation = 0) # match default histogram formatting

    ## Fig 3: Area hist plots
    axi = np.take(ax3, i)
    axi.hist(lakes[filter].area_px_m2/1e6, alpha=0.4, color='g', label=label, bins=bins)
    axi.set_xlabel('Area ($km^2$)')
    axi.set_ylabel('Count')
    axi.set_yscale('log')
    axi.set_title(f'{label}', fontsize=16)
    axi.set_xlim(0, max_area_to_plot)

## save fig 1
figname=os.path.join(fig_dir, 'Hists-subplots')
fig.savefig(figname + '.jpg', dpi=300)
fig.savefig(figname + '.pdf', dpi=300)
fig.show(block=False)

## save fig 2: by area
figname=os.path.join(fig_dir, 'Hists-by-area-subplots')
fig2.savefig(figname + '.jpg', dpi=300)
fig2.savefig(figname + '.pdf', dpi=300)

## save fig 3: by area
figname=os.path.join(fig_dir, 'Area-hists-subplots')
fig3.savefig(figname + '.jpg', dpi=300)
fig3.savefig(figname + '.pdf', dpi=300)

plt.show() # Block Defaults to True in non-interactive mode and to False in interactive mode (see pyplot.isinteractive).

pass # for breakpoint