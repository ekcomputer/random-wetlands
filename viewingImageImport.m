% inputs: path to training scene images
% outputs: training data as binary rasters,(training image merged as a 3 or
% 6-band raster)
% TODO: run again and compare to prev C3 and T3
%% I/O
clear; close all
Env_PixelClassifier % load environment vars
vrt_pth=[env.tempDir, 'nband_image.vrt'];
% n=1; % file number from input
%% load / gdal VRT stack / path formatting
for n=1:length(env.input)
    txt=sprintf('Warning: input type chosen as: %s', env.inputType);
    if strcmp(env.inputType, 'Freeman')
        f.num_bands=3;
        env.input(n).im_dir_nband=[env.input(n).im_dir, 'freeman', filesep, 'C3', filesep, ''];
        f.gray_imgs=ls([env.input(n).im_dir_nband, 'Freeman_*.bin']);
    elseif strcmp(env.inputType, 'C3')
        f.num_bands=9;
        env.input(n).im_dir_nband=[env.input(n).im_dir, 'C3', filesep, ''];
        f.gray_imgs=ls([env.input(n).im_dir_nband, 'C*.bin']); % for wildcard use ?
        warning(txt)
    elseif strcmp(env.inputType, 'Freeman-T3')
        f.num_bands=3;
        env.input(n).im_dir_nband=[env.input(n).im_dir, 'freeman', filesep, 'T3', filesep, ''];
        f.gray_imgs=ls([env.input(n).im_dir_nband, 'Freeman_*.bin']);
        warning(txt)
    elseif strcmp(env.inputType, 'gray')
        f.num_bands=1;
        warning(txt)
    else
        warning(txt)
        error('Unrecognized input type (EK).') 
    end

    %

    %% format names
    f.dirs=repmat(env.input(n).im_dir_nband, size(f.gray_imgs, 1),1);
    f.pths=[f.dirs, f.gray_imgs];
    f.gray_imgs_formatted=strjoin(cellstr(f.pths([1 3 2],:)), ' ');
%     stack_path_0=[env.tempDir, env.input(n).name, '_S', num2str(f.num_bands), '_0.tif'];
    % stack_path=[env.output.train_dir, env.input(n).name, '_S', num2str(f.num_bands), '.tif'];
        % use natural name w new extension
    stack_path=[env.viewingImageDir, env.input(n).name, '_FrRGB.tif'];
    % meta_dir=[env.output.train_dir,'meta\'];
    % mkdir(meta_dir);
    % meta_path=[meta_dir, 'I00', num2str(n),'.txt'];
    % meta_mat_path=[meta_dir, 'I00', num2str(n),'.mat'];

    if ~ismember(size(f.pths, 1), [1 3 9])
       warning('check inputs') 
       return
    end

    %% gdal warp to project and select bounding box of training image
    if exist(stack_path)==0
        fprintf('Creating raster stack at:\n\t%s.\n', stack_path)
            % stack (build VRT)
        cmd=sprintf('gdalbuildvrt -separate %s %s', vrt_pth, f.gray_imgs_formatted)
        system(cmd);
            % gdal warp
        cmd=sprintf('gdalwarp "%s" "%s" -srcnodata 0 -dstnodata 0 -multi -wo NUM_THREADS=2 -co COMPRESS=DEFLATE -overwrite -t_srs PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]',...
        vrt_pth, stack_path)
        system(cmd); % note this produces an uncompressed tif
            % gdal translate
%         cmd=sprintf('gdal_translate "%s" "%s" -co COMPRESS=LZW',...
%         stack_path_0, stack_path)
%         system(cmd);
%         delete(stack_path_0);
    else
        fprintf('\n\tViewing image already existed.  Not reprocessing.\n\n')
    end
end