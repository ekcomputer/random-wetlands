function add_tiff_georef(path)
% script to write a geotiff file from a tif file, proj file and tfw file.
% Sloppy becasue could use numerical
% inputs to give georef...but that would take too long to write r/n.
% Uses CRS EPSG;102001 by default.
% Called by biggeotiffwrite.m

% Inputs:   path    =   filename of tiff. Needs to have corresponding .prof
%                       and .tfw
%           im      =   image matrix (mxnx1)
%
%
% Output:   Uses gdal edit to rewrite tiff header and update file

% Written  by Ethan Kyzivat

% use gdal_edit and values from other matlab I/O functions
% to re-assign SRS info if image is normal tif + tfw and
% proj
worldfile=[path(1:end-4), '.tfw'];
im_info=imfinfo(path);
co=worldfileread(worldfile, 'planar', [im_info.Height, im_info.Width]);
bb=[co.XWorldLimits(1), co.YWorldLimits(2), co.XWorldLimits(2), co.YWorldLimits(1)];
cmd=sprintf('gdal_edit.py -a_srs "EPSG:102001" -a_ullr %s %s', num2str(bb), path)
system(cmd);