% inputs: shapefile with class names; path to training scene images
% outputs: training data as binary rasters snapped to training images;
% training image merged as a 3 or 6-band raster

% TODO: ensure ENVI header b.b. is updated if using UAVSAR clip; modify to
% work on n-band images, reproject, nudge to get alignment bw UAVSAR and
% training data, add bounding box input to create smaller training file tif
%% I/O
clear; close all
Env_PixelClassifier % load environment vars
vrt_pth=[env.tempDir, 'nband_image.vrt'];
n=1; % file number from input
%% load / gdal VRT ? path formatting

if strcmp(env.inputType, 'Freeman')
    f.num_bands=3;
    env.input(n).im_dir_nband=[env.input.im_dir, 'freeman\C3\'];
    f.gray_imgs=ls([env.input(n).im_dir_nband, 'Freeman_*.bin']);
elseif strcmp(env.inputType, 'C3')
    f.num_bands=9;
    env.input(n).im_dir_nband=[env.input.im_dir, 'C3\'];
    f.gray_imgs=ls([env.input(n).im_dir_nband, 'C*.bin']); % for wildcard use ?
elseif strcmp(env.inputType, 'gray')
    f.num_bands=1;
else
    error('Unrecognized input type (EK).')
end
f.dirs=repmat(env.input(n).im_dir_nband, size(f.gray_imgs, 1),1);
f.pths=[f.dirs, f.gray_imgs];
f.gray_imgs_formatted=strjoin(cellstr(f.pths([1 3 2],:)), ' ');

if ~ismember(size(f.pths, 1), [1 3 9])
   warning('check inputs') 
   return
end
%

cmd=sprintf('gdalbuildvrt -separate %s %s', vrt_pth, f.gray_imgs_formatted)
system(cmd)
%% gdal warp 
stack_path_0=[env.tempDir, env.input(1).name, '_S', num2str(f.num_bands), '_0.tif'];
stack_path=[env.tempDir, env.input(1).name, '_S', num2str(f.num_bands), '.tif'];
cmd=sprintf('gdalwarp "%s" "%s" -srcnodata 0 -dstnodata 0 -multi -t_srs PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]',...
    vrt_pth, stack_path_0);
system(cmd) % note this produces an uncompressed tif

    % gdal translate
cmd=sprintf('gdal_translate "%s" "%s" -co COMPRESS=LZW',...
    stack_path_0, stack_path);
system(cmd)
delete(stack_path_0)

%% load shp
gt=geotiffinfo(stack_path);
class_number=11; % for class_number=1:length(env.class_names)
training_pth=[env.output.train_dir, 'I00', num2str(n),'_Class', num2str(class_number), '.tif'];

%%
wkt='PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]';
    % WHERE
% cmd=sprintf('gdal_rasterize -ts %f %f -te %f %f %f %f -burn 10 -co "COMPRESS=DEFLATE" -ot Byte -l training2018PAD -where "Class = ''%s''" -a_srs PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]] %s %s', ...
%     gt.Width, gt.Height, gt.BoundingBox(1),gt.BoundingBox(3), gt.BoundingBox(2),...
%     gt.BoundingBox(4), env.class_names{class_number}, env.input(n).cls_pth,...
%     training_pth )

    % SQL
% cmd=sprintf('gdal_rasterize -ts %f %f -te %f %f %f %f -burn 1 -co "COMPRESS=DEFLATE" -ot Byte -l training2018PAD -sql "SELECT * FROM training2018PAD WHERE Class = ''%s''" -a_srs PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]] %s %s', ...
%     gt.Width, gt.Height, gt.BoundingBox(1),gt.BoundingBox(3), gt.BoundingBox(2),...
%     gt.BoundingBox(4), env.class_names{class_number}, env.input(n).cls_pth,...
%     training_pth )

    %test 1
% cmd=sprintf('gdal_rasterize -ts %f %f -te %f %f %f %f -burn 10 -co "COMPRESS=DEFLATE" -ot Byte -a_srs %s %s %s', ...
%     gt.Width, gt.Height, gt.BoundingBox(1),gt.BoundingBox(3), gt.BoundingBox(2),...
%     gt.BoundingBox(4), wkt,env.input(n).cls_pth,...
%     training_pth )

    %test 2 no SQL or WHERE or WKT
cmd=sprintf('gdal_rasterize -ts %f %f -te %f %f %f %f -burn 10 -co "COMPRESS=DEFLATE" -ot Byte -l training2018PAD %s %s', ...
    gt.Width, gt.Height, gt.BoundingBox(1),gt.BoundingBox(3), gt.BoundingBox(2),...
    gt.BoundingBox(4), env.input(n).cls_pth,...
    training_pth )

system(cmd)
% todo: automate layer name 2x
    % note : next timed use -tap with -tr [xres, yres]
    
foo=imread(training_pth);
max(foo(:))