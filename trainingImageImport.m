% inputs: shapefile with class names; path to training scene images
% outputs: training data as binary rasters snapped to training images;
% training image merged as a 3 or 6-band raster
% 
%% I/O
clear; close all
Env_PixelClassifier % load environment vars
vrt_pth=[env.tempDir, 'nband_image.vrt'];
for n=[1 2]; % file number from input
    %% load / gdal VRT stack / path formatting

    if strcmp(env.inputType, 'Freeman')
        f.num_bands=3;
        env.input(n).im_dir_nband=[env.input(n).im_dir, 'freeman\C3\'];
        f.gray_imgs=ls([env.input(n).im_dir_nband, 'Freeman_*.bin']);
    elseif strcmp(env.inputType, 'C3')
        f.num_bands=9;
        env.input(n).im_dir_nband=[env.input(n).im_dir, 'C3\'];
        f.gray_imgs=ls([env.input(n).im_dir_nband, 'C*.bin']); % for wildcard use ?
    elseif strcmp(env.inputType, 'gray')
        f.num_bands=1;
    else
        error('Unrecognized input type (EK).')
    end

    %

    %% format names
    f.dirs=repmat(env.input(n).im_dir_nband, size(f.gray_imgs, 1),1);
    f.pths=[f.dirs, f.gray_imgs];
    f.gray_imgs_formatted=strjoin(cellstr(f.pths([1 3 2],:)), ' ');
    % stack_path_0=[env.tempDir, env.input(n).name, '_S', num2str(f.num_bands), '_0.tif'];
    % stack_path=[env.output.train_dir, env.input(n).name, '_S', num2str(f.num_bands), '.tif'];
    stack_path=[env.output.train_dir, env.input(n).name, '_', num2str(n),'.tif'];
    meta_dir=[env.output.train_dir,'meta\'];
    mkdir(meta_dir);
    meta_path=[meta_dir, env.input(n).name, '_', num2str(n),'.txt'];
    meta_mat_path=[meta_dir, env.input(n).name, '_', num2str(n),'.mat'];

    if ~ismember(size(f.pths, 1), [1 3 9])
       warning('check inputs') 
       return
    end
    %%  save log files
    fid=fopen(meta_path, 'w+');
    fprintf(fid, 'Name:\t\t%s\n', env.input(n).name)
    fprintf(fid, 'L-band directory:\t\t%s\n', env.input(n).im_dir)
    % fprintf(fid, 'Classes (%d):\t\t%s\n', strjoin(cellstr(env.class_names), ' '))
    fprintf(fid, 'Classes:\n');
    for m=1:length(env.class_names)
        fprintf(fid, '\t\t%d\t%s\n', m,env.class_names{m});
    end

    save(meta_mat_path, 'env');

    %% get bounding box of training shapefile
    R=shapeinfo(env.input(n).cls_pth);
    f.bb=R.BoundingBox([1 3 2 4]);
    f.bb_fmtd=num2str(f.bb);
    %% gdal warp to project and select bounding box of training image
    if exist(stack_path)==0
            % stack (build VRT)
        cmd=sprintf('gdalbuildvrt -separate %s %s', vrt_pth, f.gray_imgs_formatted)
        system(cmd);
            % gdal warp
            cmd=sprintf('gdalwarp "%s" "%s" -srcnodata 0 -dstnodata 0 -multi -wo NUM_THREADS=2 -co COMPRESS=DEFLATE -te %s -t_srs PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]',...
        vrt_pth, stack_path, f.bb_fmtd)
        system(cmd); % note this produces an uncompressed tif
            % gdal translate
    %     cmd=sprintf('gdal_translate "%s" "%s" -co COMPRESS=LZW',...
    %     stack_path_0, stack_path)
    %     system(cmd);
    %     delete(stack_path_0)
    else
        fprintf(fid, 'Training image already existed.\n')
        fprintf('Training image already existed.  Not reprocessing.\n')
    end

    fclose(fid);
    %% load shp and create training class rasters (1/class)

        % for creatin gempty files:
    info=geotiffinfo(stack_path);
    for class_number=1:length(env.class_names) % class_number=11; % 
            % training path zero is in temp dir for rasters b/f training/val
            % split and erosion, if any
%         training_pth=[env.tempDir, env.input(n).name, '_', num2str(n),'_TmpClass', num2str(class_number), '.tif'];
        training_pth=[env.output.train_dir, env.input(n).name, '_', num2str(n),'_Class', num2str(class_number), '.tif'];
%         val_pth=[env.output.val_dir, env.input(n).name, '_', num2str(n),'_ValClass', num2str(class_number), '.tif'];
        
        gt=geotiffinfo(stack_path);
        % wkt='PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]';
        [~, f.layer_name, ~]=fileparts(env.input(n).cls_pth);

        cmd=sprintf('gdal_rasterize -ts %f %f -te %f %f %f %f -burn 1 -co "COMPRESS=DEFLATE" -ot Byte -l %s -where "Class = ''%s''" %s %s',...
            gt.Width, gt.Height, gt.BoundingBox(1),gt.BoundingBox(3), gt.BoundingBox(2),...
            gt.BoundingBox(4), f.layer_name, env.class_names{class_number}, env.input(n).cls_pth,...
            training_pth)
        system(cmd);
        i=dir(training_pth);
        if i.bytes< 100
            imwrite(zeros([info.Height, info.Width], 'uint8'),training_pth); % sloppy fix; no geospatial info
    %         delete(training_pth)
            fprintf('\n\tCreating empty training image: %s\n\n', training_pth)
        end
    
            % load temp training path, reshape, partition to training/val,
            % re-write
%         [im, R]=geotiffread(training_pth);
%         f.gti=geotiffinfo(training_pth);
%         im_vect=double(im(:)); im_vect(im_vect==0)=NaN;
%         c=cvpartition(im_vect ,'KFold',env.valPartitionRatio);
            % add erosion here if using to modify 'im'
        
    end
end