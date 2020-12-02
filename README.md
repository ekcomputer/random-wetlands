# Instructions for using these scripts
These instructions are designed for the Above Science Cloud (ASC) environment, but you will need to install the required packages and conda env  beforhand, regardless!

[comment]: <> (![ASC](https://above.nasa.gov/images/ASC_logo.jpg =100x)

<p align="center">
    <img src="https://above.nasa.gov/images/ASC_logo.jpg" width="200" alt="ASC" text-align="center"/>  
</p>

## Workflow for LUT-based classification
* This method was used for the Daring Lake scenes.

0. Activate conda environment. On ABoVE Science Cloud (ASC), the command would be:

>```
>conda activate base
>```
1. Move original GRD files to default_grd folder, using the script [polsar_pro/psp_mv_hgt_slope_inc_function.sh](polsar_pro/psp_mv_hgt_slope_inc_function.sh).

2. Run python script [radiocal_example_script_ek.py](https://github.com/ekcomputer/UAVSAR-Radiometric-Calibration/blob/master/python/radiocal_example_script_ek.py) located in an additional forked [repo](https://github.com/ekcomputer/UAVSAR-Radiometric-Calibration).

3. Run polsar pro workflow in parallel using the following command:
>```
> bash polsar_pro/parallel_cat_run.sh polsar_pro/psp_workflow_function.sh [path/to/textfile/with/input/IDs] [number of cores]
>```
> Number of cores: 2 recommended to conserve memory on ASC, since each function call will need ~40 GB of mem max dand cause un-noticed errors if memory limit is exceeded
>