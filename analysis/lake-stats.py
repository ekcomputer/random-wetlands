# plotting
'''
0. For PAD and YF: choose inner ROI
1. Seed with CIR maks lakes (to help YF)
1.5. Filter out edge lakes and small lakes
2. "Spatial bootstrapping"
3. Histograms of EM% and EM% binned by size
4. Choose best dates (in notebook) or multi-temporal hist

TODO: 
    * Dateparser for dates in filename
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
min_size=2000 # meters squared

## constants

## load data
files_in=glob.glob(os.path.join(shape_dir, '*.shp'))
lakes_list=[]

## Plotting params
# plt.rcParams
# plt.style.use('seaborn')
plt.style.use('/mnt/d/Dropbox/Python/Matplotlib-rcParams/presentation.mplstyle')

## loop
for i, filename in enumerate(files_in):
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

## Multi-termporal plot
# fig, ax = plt.subplots()
colors=['b','g','r']
for i, lakes in enumerate(lakes_list):
    plt.hist(lakes.em_fractio, alpha=0.2, color=colors[i], label=os.path.basename(files_in[i]))
# ax.legend()
# fig.show()
plt.ylabel('Lake count')
plt.xlabel('Emergent macrophyte fraction')
plt.title(f'Lakes > {min_size} m2 ({min_size/px_area:.0f} px)')
plt.legend()

## save fig
figname=os.path.join(fig_dir, 'Hists-time')
plt.savefig(figname + '.jpg', dpi=300)
plt.savefig(figname + '.pdf', dpi=300)
plt.show()
pass # for breakpoint