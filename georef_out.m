function addOutputImages(name, im)
% script to write a geotiff from just a filename and image matrix.  It
% calls global env structure to query input image with same name so it can
% extact georef info and masked pixels.

% Inputs:   name    =   file basename as found in training folder (eg
%                         ('yflatE_21609_17098_008_170916_L090_CX_01_Freeman-inc')
%           im      =   image matrix (mxnx1)
% Output:   None, but it writes a file 

% modified from addOutputImages.m
% Written  by Ethan Kyzivat

%% I/O
global env

%% Load georef info
georef_in=(ls([env.output.test_dir, name, '.tif']));
if ~isunix
    output_pth=[env.output.test_dir, georef_in(1,1:end-4), '_cls.tif'];
    gt=geotiffinfo([env.output.test_dir, georef_in]);
else
    output_pth=[georef_in(1,1:end-5), '_cls.tif'];
    gt=geotiffinfo(georef_in(1,1:end-1));   % hot fix
end

%% apply mask

if ~isunix
    test_im=imread([env.output.test_dir, georef_in]);
else
    test_im=imread(strtrim(georef_in));
end
mask=isnan(test_im(:,:,end)); % negative data mask
im(mask)=env.constants.noDataValue_ouput; %%% HERE 2/18/20: mask is different size than out
%% write
geotiffwrite(output_pth, im, gt.SpatialRef, 'GeoKeyDirectoryTag',gt.GeoTIFFTags.GeoKeyDirectoryTag);
% gdal_calc.py -A input1.tif -B input2.tif --outfile=result.tif --calc="A+B"

%% Add NoData values to rasters
if 1==1 % don't implement until ASC updates python gdal to 2.1.2 +
    cmd=sprintf('gdal_edit.py -a_nodata %d %s', env.constants.noDataValue_ouput, output_pth);
    system(cmd)
end