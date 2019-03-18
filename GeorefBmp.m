% for georeferencing PolSAR PRO output BMP files
% modified form importGRD.m
% modified march 2019 for ui open
% TODO: add gdal_edit to edit NoData value to be [0 1 0]

clear; close all

%% input directories
disp('Choose bitmap image directory:')
dir_in=[uigetdir('F:\UAVSAR\','Choose root directory:'),'\'];
[name_in, pth_in]=uigetfile([dir_in, '*.bmp'],'Choose bitmap image:');
dir_out=[pth_in, 'Georeferenced\'];
ann_file_pth=[dir_in, 'annotation_file.txt'];

%% input params
% (set to zero if not subset)
% lat_offset would be larger value in POLSAR Pro subset dialogue box
s.lat_offset=20001;% offset in pixel rows + 1 if subset was used 
s.long_offset=0; % offset in pixel cols if subset was used

%% load files

disp('Importing file...')
im=imread([pth_in,name_in]);
fid=fopen(ann_file_pth);
s.in.raw=textscan(fid, '%s', 'Delimiter', '\n'); s.in.raw=s.in.raw{:};
fclose(fid);
disp('File imported.')
%% mkdir

if~exist(dir_out)
    mkdir(dir_out);
end

%% parse georef info
s.in.info=imfinfo([pth_in,name_in]);
    % lat spacing
s.in.lat_spacing_row_txt=strfind(s.in.raw, 'grd_mag.row_mult');
s.in.lat_spacing_row_num=find(~cellfun(@isempty, s.in.lat_spacing_row_txt));
s.in.lat_spacing_row_scan=textscan(s.in.raw{s.in.lat_spacing_row_num}, '%s')
s.lat_spacing=str2double(s.in.lat_spacing_row_scan{1}{4});
    %long spacing
s.in.long_spacing_row_txt=strfind(s.in.raw, 'grd_mag.col_mult');
s.in.long_spacing_row_num=find(~cellfun(@isempty, s.in.long_spacing_row_txt));
s.in.long_spacing_row_scan=textscan(s.in.raw{s.in.long_spacing_row_num}, '%s')
s.long_spacing=str2double(s.in.long_spacing_row_scan{1}{4});

    % lat
s.in.lat_row_txt=strfind(s.in.raw, 'grd_mag.row_addr');
s.in.lat_row_num=find(~cellfun(@isempty, s.in.lat_row_txt));
s.in.lat_row_scan=textscan(s.in.raw{s.in.lat_row_num}, '%s')
s.lat=str2double(s.in.lat_row_scan{1}{4});

    % long
s.in.long_row_txt=strfind(s.in.raw, 'grd_mag.col_addr');
s.in.long_row_num=find(~cellfun(@isempty, s.in.long_row_txt));
s.in.long_row_scan=textscan(s.in.raw{s.in.long_row_num}, '%s')
s.long=str2double(s.in.long_row_scan{1}{4});


%% apply offset if subset was used

s.lat=s.lat+s.lat_offset*s.lat_spacing; %% assumes rows start from north
s.long=s.long+s.long_offset*s.long_spacing; %% assumes rows start from north

%% multiband import
r.y=s.in.info.Height; %raster info: pixels
r.x=s.in.info.Width;
r.py=s.lat_spacing; %pixel size % GRD Latitude Pixel Spacing
r.px=s.long_spacing;
r.lat=s.lat; %NW corner coords %Center Latitude of Upper Left Pixel of GRD Image 
r.long=s.long;
disp('adding spatial reference...')

%% Define and modify spatial ref
R=georefcells();
R.RasterSize=[r.y r.x];
R.LatitudeLimits=sort([r.lat-r.py*r.y, r.lat]);
R.LongitudeLimits=sort([r.long  r.long+r.px*r.x]);
if s.lat_spacing <0
    R.ColumnsStartFrom='north';
else
    R.ColumnsStartFrom='south';
end
R.CellExtentInLatitude=abs(r.py);
R.CellExtentInLongitude=abs(r.px);
R.ColumnsStartFrom= 'north';

%% Write georeferenced file
name_base=textscan(dir_in, '%s', 'Delimiter', '\');
location=[dir_out,name_base{1}{3},'_', name_in(1:end-4), '_G.tif'];
fprintf('writing file: %s\n', location)
geotiffwrite(location, im, R);
figure; 
imagesc(im); 
axis image; 
colormap copper
title(name_in, 'FontSize', 10)
disp('Done!')
fprintf('File saved to %s\n', location)

%% Write world file
% worldfilename = getworldfilename(file_in);
% worldfilewrite(R, worldfilename)