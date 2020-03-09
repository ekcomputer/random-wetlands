% inputs: shapefile with class names; path to training scene images
% outputs: training data as binary rasters snapped to training images;
% training image merged as a 3 or 6-band raster
% 

%% User params
clear; close all
%% I/O
Env_PixelClassifier % load environment vars
trainingClassRasters=env.trainingClassRasters; % set to 1 to make training class rasters; 0 for viewing image only

for n=env.trainFileNums; % file number from input
    %% load / gdal VRT stack / path formatting
        
        % options
        if trainingClassRasters
            stack_path=[env.output.train_dir, env.input(n).name, '_', env.inputType,'.tif'];
            vrt_pth=[env.output.train_dir, env.input(n).name, '_', env.inputType,'.vrt'];
        else
            stack_path=[env.output.test_dir, env.input(n).name, '_', env.inputType,'.tif'];
            vrt_pth=[env.output.test_dir, env.input(n).name, '_', env.inputType,'.vrt'];
        end
        
        % display I/O params for visual check
        disp('Check to make sure I/O paths are corret:')
        fprintf('Training class path:\t %s\n', env.input(env.trainFileNums).cls_pth)
        fprintf('Training dir: \t%s\n', env.output.train_dir)
        fprintf('Test dir: \t%s\n', env.output.test_dir)
        fprintf('File numbers: \t%s\n', num2str(env.trainFileNums))
        f.names={env.input.name};
        fprintf('File IDs:\n');
        disp(f.names(env.trainFileNums)')
        fprintf('Input type: \t%s\n', env.inputType)
        fprintf('Rangecorrection: \t%d\n', env.rangeCorrection);
        if trainingClassRasters==0;
            disp('Making stacked image only- no training class rasters.  Output to test folder')
        else
            disp('Making stacked image and training class rasters.')
        end
        disp('Press any key to continue')
        if n==env.trainFileNums(1)
            pause()
        end

        % common to all if branches
    env.input(n).im_dir_nband=[env.input(n).im_dir, 'freeman', filesep, 'C3', filesep, ''];
    env.input(n).im_dir_nband_c=[env.input(n).im_dir, 'C3', filesep, ''];
%     if isunix
%         f.inc_dir=dir(['/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/INC/UA',...
%             filesep,  env.input(n).name, '.inc']);
%     else
    f.inc_dir=dir([env.input(n).im_dir,'raw', filesep, '*inc']); % if using, fix for unix
%     end
    f.gray_imgs_freeman=dir([env.input(n).im_dir_nband, 'Freeman*.bin']);
    f.gray_imgs_c3=dir([env.input(n).im_dir_nband_c, 'C*.bin']);
    if isempty(f.inc_dir) || size(f.inc_dir, 1) > 1 || isempty(f.gray_imgs_freeman)...
            || isempty(f.gray_imgs_c3) 
        warning('No < inc, freeman, or C3 > file found.')
        continue
    end
    f.inc=f(1).inc_dir.name;
    if exist([env.input(n).im_dir, 'raw', filesep, env.input(n).name, '.inc.hdr']) ~= 2 % if inc.hdr DNE
        copyfile([env.input(n).im_dir,'C3', filesep, 'mask_valid_pixels.bin.hdr'], [env.input(n).im_dir, 'raw', filesep, env.input(n).name, '.inc.hdr']);
        f.w=sprintf('Creating inc.hdr file: %s\n', [env.input(n).im_dir, 'raw', filesep, env.input(n).name, '.inc.hdr']);
        warning(f.w);
    end
                % merge structures
    f.gray_imgs_freeman_tbl=struct2table(f.gray_imgs_freeman); 
    f.gray_imgs_c3_tbl=struct2table(f.gray_imgs_c3);
    f.gray_imgs_inc_tbl=struct2table(f.inc_dir);
    f.gray_imgs=table2struct([f.gray_imgs_freeman_tbl; f.gray_imgs_c3_tbl;...
        f.gray_imgs_inc_tbl]);
    
        % format paths
    for k=1:length(f.gray_imgs)
        f.pths{k}=[f.gray_imgs(k).folder, filesep, f.gray_imgs(k).name]; 
    end
    f.max_num_bands=length(f.gray_imgs);
        % ADD BRANCHES % pick out specific bands and orders
    if strcmp(env.inputType, 'Freeman')      
        f.band_order=[1 3 2];
    elseif strcmp(env.inputType, 'Freeman-inc')
        f.band_order=[1 3 2 f.max_num_bands];
    elseif strcmp(env.inputType, 'C3-inc')
        f.band_order=[4:12, f.max_num_bands];
    elseif strcmp(env.inputType, 'Norm-Fr-C11-inc') % Fr-C11-C33-inc %% this branch uses linux or windows compatible dir instead of ls
        f.band_order=[1 3 2 4 f.max_num_bands];
    elseif strcmp(env.inputType, 'C3')
        f.band_order=[4:12];
    elseif strcmp(env.inputType, 'gray')
        f.band_order=[4];
    else
        error('Unrecognized input type (EK).')
    end
       % format for gdal VRT
    f.gray_imgs_formatted=strjoin({f.pths{f.band_order}}, ' '); % DYNAMIC
    %

    %% defensive check
    if ~ismember(length({f.pths{f.band_order}}), [1 3 4 5 10]) && ~isunix
       warning('check inputs') 
       return
    end

    %%  save log files
    meta_dir=[env.output.train_dir,'meta', filesep, ''];
    mkdir(meta_dir);
    meta_path=[meta_dir, env.input(n).name, '_', num2str(n),'.txt'];
    meta_mat_path=[meta_dir, env.input(n).name, '_', num2str(n),'.mat'];

    fid=fopen(meta_path, 'w+');
    fprintf(fid, 'Name:\t\t%s\n', env.input(n).name);
    fprintf(fid, 'L-band directory:\t\t%s\n', env.input(n).im_dir);
    % fprintf(fid, 'Classes (%d):\t\t%s\n', strjoin(cellstr(env.class_names), ' '))
    fprintf(fid, 'Classes:\n');
    for m=1:length(env.class_names)
        fprintf(fid, '\t\t%d\t%s\n', m,env.class_names{m});
    end

    save(meta_mat_path, 'env');

    %% get bounding box of training shapefile or input bounding box
    if trainingClassRasters
        R=shapeinfo(env.input(n).cls_pth);
        f.bb=R.BoundingBox([1 3 2 4]);
        f.bb_fmtd=num2str(f.bb);
    else
        if ~isempty(env.input(n).bb)
            f.bb=env.input(n).bb;
            
                % check bb fits inside of image
            f.bb_area=(f.bb(3)-f.bb(1))*(f.bb(4)-f.bb(2));
            if f.bb_area> 5e10
                warning('Input bounding box area is greater than 50,000 km2') 
            elseif f.bb_area> 5e12
                error('Input bounding box area is greater than 5,000,000 km2') 
            end
            f.bb_fmtd=num2str(f.bb);
            useFullExtent=0;
        else
            useFullExtent=1;
            disp('No training rasters used, but no bounding box defined.  Using full extent.')
        end
    end
    %% gdal warp to project and select bounding box of training image
    if exist(stack_path)==0
            % stack (build VRT)
        cmd=sprintf('gdalbuildvrt -separate %s %s', vrt_pth, f.gray_imgs_formatted)
        system(cmd);
            % gdal warp
        if ~useFullExtent % is srcnodata really -10000 or is it zero?
            cmd=sprintf('gdalwarp "%s" "%s" -srcnodata -10000 -dstnodata -10000 -multi -wo NUM_THREADS=2 -co COMPRESS=DEFLATE -te %s -t_srs PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]',...
                vrt_pth, stack_path, f.bb_fmtd)
        else
            cmd=sprintf('gdalwarp "%s" "%s" -srcnodata -10000 -dstnodata -10000 -multi -wo NUM_THREADS=2 -co COMPRESS=DEFLATE -t_srs PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]',...
                vrt_pth, stack_path)
        end
        system(cmd);
                % gdal translate
        %     cmd=sprintf('gdal_translate "%s" "%s" -co COMPRESS=LZW',...
        %     stack_path_0, stack_path)
        %     system(cmd);
        %     delete(stack_path_0)
    
        %% range correction and/or normalization
    
        if strcmp(env.inputType, 'Norm-Fr-C11-inc') || env.rangeCorrection %% load geotiff into mem
            [stack, R]=geotiffread(stack_path);
            gti=geotiffinfo(stack_path);
            nBands=length(f.band_order);
            stack(repmat(stack(:,:,nBands)==env.constants.noDataValue, [1, 1, nBands]))=NaN;
            if env.rangeCorrection % fix NoData value issues...
                if strcmp(env.inputType, 'Freeman-inc') || strcmp(env.inputType, 'C3-inc')
                    disp('Range correction...')
                    stack(:,:,1:end-1)=stack(:,:,1:end-1).*(cosd(env.constants.imCenter)./cos(stack(:,:,end))).^env.constants.n;
                    stack(repmat(stack(:,:,1)==env.constants.noDataValue, [1, 1, nBands]))=env.constants.noDataValue;    %mask out nodata
                elseif strcmp(env.inputType, 'Norm-Fr-C11-inc')
                    disp('Range correction...')
                    stack(:,:,4)=stack(:,:,4).*(cosd(env.constants.imCenter)./cos(stack(:,:,end))).^env.constants.n;
                    stack(repmat(stack(:,:,1)==env.constants.noDataValue, [1, 1, nBands]))=env.constants.noDataValue;    %mask out nodata
               else
                    error('check input class')
                end
            end
                
                % normalization
            if strcmp(env.inputType, 'Norm-Fr-C11-inc') 
                disp('Freeman normalization...')
                stack(:,:,1:3)=stack(:,:,1:3)./sum(stack(:,:,1:3), 3);
            end
                
                % another check to make sure correct bounding box was used
                
                f.sumValidpx=sum(sum(stack(:,:,1)>0));
                if f.sumValidpx < 5000
                   warning('Output tif has less than 5,000 valid pixels.')
                end
                % write using geotiffwrite and add mask using gdal
                lastwarn('') % reset
                [warnMsg, warnId] = lastwarn;
                    % Try
                geotiffwrite([stack_path, '_temp.tif'],stack, R, 'GeoKeyDirectoryTag',gti.GeoTIFFTags.GeoKeyDirectoryTag)
                if ~isempty(warnMsg)
                    disp('Writing big geotiff')
                    biggeotiffwrite([stack_path, '_temp.tif'],stack, R, env.proj_source);
                end
                    % can use gdal edit instead...
            cmd=sprintf('gdalwarp "%s" "%s" -overwrite -srcnodata -10000 -dstnodata -10000 -multi -wo NUM_THREADS=2 -co COMPRESS=DEFLATE',...
                [stack_path, '_temp.tif'], stack_path)
            system(cmd);
            delete([stack_path, '_temp*']);
        end
        
    else
        fprintf(fid, 'Training image already existed.\n')
        fprintf('Training image already existed.  Not reprocessing.\n')
    end

    fclose(fid);
    %% load shp and create training class rasters (1/class)

        % for creatin gempty files:
    if trainingClassRasters==1 % build training class rasters
        gt=geotiffinfo(stack_path);
        for class_number=1:length(env.class_names) % class_number=11; % 
                % training path zero is in temp dir for rasters b/f training/val
                % split and erosion, if any
    %         training_pth=[env.tempDir, env.input(n).name, '_', num2str(n),'_TmpClass', num2str(class_number), '.tif'];
            training_pth=[env.output.train_dir, env.input(n).name, '_', env.inputType,'_Class', sprintf('%02d',class_number), '.tif'];
    %         val_pth=[env.output.val_dir, env.input(n).name, '_', num2str(n),'_ValClass', num2str(class_number), '.tif'];
                    % wkt='PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["latitude_of_center",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]';
            [~, f.layer_name, ~]=fileparts(env.input(n).cls_pth);

            cmd=sprintf('gdal_rasterize -ts %f %f -te %f %f %f %f -burn 1 -co "COMPRESS=DEFLATE" -ot Byte -l %s -where "Class = ''%s''" %s %s',...
                gt.Width, gt.Height, gt.BoundingBox(1),gt.BoundingBox(3), gt.BoundingBox(2),...
                gt.BoundingBox(4), f.layer_name, env.class_names{class_number}, env.input(n).cls_pth,...
                training_pth)
            system(cmd);
            i=dir(training_pth);
            if i.bytes< 100
                imwrite(zeros([gt.Height, gt.Width], 'uint8'),training_pth); % sloppy fix; no geospatial info
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
end