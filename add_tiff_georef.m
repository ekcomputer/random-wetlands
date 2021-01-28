function add_tiff_georef(path, varargin)
% script to write a geotiff file from a tif file, proj file and tfw file.
% Sloppy becasue could use numerical
% inputs to give georef...but that would take too long to write r/n.
% Uses CRS EPSG:102001 by default.
% Called by biggeotiffwrite.m

% Inputs:   path            =   filename of tiff. Needs to have corresponding .proj
%                               and .tfw
%           im              =   image matrix (mxnx1)
%           geotiff_pth     =   [optional] path to image of same dimensions
%                               with proper georeferencing. Uses this
%                               instead of .tfw and .proj
%           no_data_value_out = [optional, but if geotiff_pth is
%                               given and no value specified, 
%                               no_data_value_out defaults to zero] number 
%                               giving value to be treated as
%                               nodata in the raster
%           
%
% Output:   Uses gdal edit to rewrite tiff header and update file

% Written  by Ethan Kyzivat

% use gdal_edit and values from other matlab I/O functions
% to re-assign SRS info if image is normal tif + tfw and
% proj
if nargin == 1 % use existing .tfw and .proj
    worldfile=[path(1:end-4), '.tfw'];
    im_info=imfinfo(path);
    co=worldfileread(worldfile, 'planar', [im_info.Height, im_info.Width]);
    bb=[co.XWorldLimits(1), co.YWorldLimits(2), co.XWorldLimits(2), co.YWorldLimits(1)];
    cmd=sprintf('gdal_edit.py -a_srs "EPSG:102001" -a_ullr %s %s', num2str(bb), path) % doesn't add nodata value for now...can change if desired
else % ignore existing .tfw and .proj and use georef from geotiff_path
    geotiff_pth = varargin{1};
    if nargin > 2
        no_data_value_out = varargin{2};
    else
        no_data_value_out = 0; % default
    end
    gt=geotiffinfo(geotiff_pth);
    bb=[gt.SpatialRef.XWorldLimits(1), gt.SpatialRef.YWorldLimits(2), gt.SpatialRef.XWorldLimits(2), gt.SpatialRef.YWorldLimits(1)];
    cmd=sprintf('gdal_edit.py -a_srs "EPSG:102001" -a_ullr %s -a_nodata %d %s', num2str(bb), no_data_value_out, path)
end
system(cmd);