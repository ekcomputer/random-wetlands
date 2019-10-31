% inputs: path to training scene images
% outputs: training data as binary rasters,(training image merged as a 3 or
% 6-band raster)

%% I/O
clear; close all
Env_PixelClassifier % load environment vars
vrt_pth=[env.tempDir, 'nband_image.vrt'];
% n=1; % file number from input
%% load / gdal VRT stack / path formatting
for n=4; %1:length(env.input)
    txt=sprintf('Warning: input type chosen as: %s', env.inputType);
    if strcmp(env.inputType, 'Freeman')
        f.num_bands=3;
        env.input(n).im_dir_nband=[env.input(n).im_dir, 'freeman\C3\'];
        f.gray_imgs=ls([env.input(n).im_dir_nband, 'Freeman_*.bin']);
    elseif strcmp(env.inputType, 'C3')
        f.num_bands=9;
        env.input(n).im_dir_nband=[env.input(n).im_dir, 'C3\'];
        f.gray_imgs=ls([env.input(n).im_dir_nband, 'C*.bin']); % for wildcard use ?
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
    stack_path_0=[env.tempDir, env.input(n).name, '_S', num2str(f.num_bands), '_0.tif'];
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
        cmd=sprintf('gdalwarp "%s" "%s" -srcnodata 0 -dstnodata 0 -multi -t_srs "F:\\UAVSAR\\Georeferenced\\proj\\102001.prj"',...
        vrt_pth, stack_path_0)
        system(cmd); % note this produces an uncompressed tif
            % gdal translate
        cmd=sprintf('gdal_translate "%s" "%s" -co COMPRESS=LZW',...
        stack_path_0, stack_path)
        system(cmd);
        delete(stack_path_0);
    else
        fprintf('\n\tViewing image already existed.  Not reprocessing.\n\n')
    end
end