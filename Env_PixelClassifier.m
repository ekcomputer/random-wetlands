% env vars for running pixel classifier

% INSTRUCTIONS:
% Update env.class_dir_local each time I have new training files.  UPdate
% env.class_dir_asc automatically as long as I update env.run

%% Preliminary
clear env
global env 

%% source gdal (try to avoid gdal_edit.py errors)
if isunix
    unix('source /opt/PGSCplus-2.2.2/init-gdal.sh')
end

%% options
load_env=0; % load env. from previous run?

%% Params for training and classifying
env.inputType='Freeman'; % tag: common %OPTIONS: 'Freeman', 'LUT-Freeman', 'C3', 'Freeman-T3' or 'gray', 'Freeman-inc', 'C3-inc', 'T3', 'Norm-Fr-C11-inc', 'Sinclair', 'Sinclair-hgt'
env.rangeCorrection=1;
env.equalizeTrainClassSizes=1; % Delete some training data so that all training classes have aprox. = sizes (not per image, but overall)
env.run='43'; % tag: common
env.IncMaskMin=0.5; %0.5; % minimum inc. angle to allow if applying incidence angle mask % only valid for Freeman, C3, T3 with no inc band used as a feature; set to zero to ignore  <------- HERE
env.IncMaskMax=Inf % 1.07; %1.0; % max inc. angle to allow if applying incidence angle mask % only valid for Freeman, C3, T3 with no inc band used as a feature; set to Inf to ignore
env.useFullExtentClassifier=false; % depricated!
env.blockProcessing=true; % whether or not to use 

%% Params for trainingImageImport.m
env.trainingClassRasters=0; % tag: common % set to 1 to make training class rasters; 0 for viewing/classification image only in the Test folder
env.training_run='43'; % tag: common % set different from env.run if using a model from previous run or training to a diff dir.  Only matters on ASC.
env.training_class_run='43'; % tag: common % for shapefiles
env.useFullExtentImport=1; % switch to use full scene extent and ignore bounding box from input runfile
env.output.cls_dir_local='/att/nobackup/ekyzivat/PixelClassifier';
env.output.cls_dir_asc='/att/nobackup/ekyzivat/PixelClassifier';
env.class_dir_local='F:\PAD2019\classification_training\Checkpoint-2020-march-12';

    % Which files to import as training images
if isunix % on ASC % tag: common
    env.trainFileNums= [1 2 3 4 7 8 9 11 13 14 15 16 17 21 22 23 24 25 27:32]; % <- all? % [46:52] %[50 48]; % (Atquasuk and Toolik) % from block-proc: [45 46 47 48 50 51 52]; %28; %[13 43 44]% 33 bonanz: 27,28 % [3 4 11 13 14 21 23 24 25 30 31 32] % didn't work: 16 17 % [1 2 7 8 9 15 22]; %[3 4 11 13 14 21 22 23 24 25]; %[3 4 11 13 14 16 17 21 22 23 24 25 x26]; %[1 2 3 4 7 8 9 11 13 14 15 16 17 21 22 23 24 25 x26] %[1, 15]; %[1,2,7,8,9,15]; %[1,2,3,4,7,8,9,13, 14, 15, 16, 17]; %; %[7]; %[1 2 8 9 10 11 12 13]; % [1 2]
else % on local
    env.trainFileNums=[1,2]; %15% [1 2]
end    

%% Dynamic I/O
env.class_dir_asc=[env.output.cls_dir_asc, filesep, 'Train', env.training_class_run, filesep, 'shp'];
if ~contains(env.inputType, 'Freeman')
    warning('Did you account for no data values without using inc band?')
end
    
if isunix
    env.gdal.CACHEMAX = 8000; %~4GB
    env.output.train_dir=[env.output.cls_dir_asc, filesep, 'Train', env.training_run, '/'];
else
    env.gdal.CACHEMAX = 2000; %~2GB
end

if ismember(env.inputType, {'Freeman','Sinclair', 'Freeman-T3', 'LUT-Freeman'}) %tag: ENV_INPUT_TYPE
    env.radar_bands=[1,2,3];
    env.inc_band=4;
    env.dem_band=NaN;
    env.use_inc_band=false; % whether or not to use as feature in classifier
elseif ismember(env.inputType, {'C3', 'T3'})
    env.radar_bands=[1:9];
    env.inc_band=NaN;
    env.dem_band=NaN;
    env.use_inc_band=false;
elseif ismember(env.inputType, {'Freeman-inc'})
    env.radar_bands=[1,2,3];
    env.inc_band=4;
    env.dem_band=NaN;
    env.use_inc_band=true;
elseif ismember(env.inputType, {'C3-inc'})
    env.radar_bands=[1:9];
    env.inc_band=10;
    env.dem_band=NaN;
    env.use_inc_band=true;
elseif strcmp(env.inputType, 'Norm-Fr-C11-inc')
    env.radar_bands=[1,2,3,4];
    env.inc_band=5;
    env.dem_band=NaN;
    env.use_inc_band=true;
elseif strcmp(env.inputType, 'gray')
    env.radar_bands=[1];
    env.inc_band=NaN;
    env.dem_band=NaN;
    env.use_inc_band=false;
elseif strcmp(env.inputType, 'Sinclair-hgt')
    env.radar_bands=[1,2,3];
    env.inc_band=NaN;
    env.dem_band=4;
    env.use_inc_band=false;
else
    error(['unrecognized input format:', env.inputType])
end
%% Constant params
if isunix
    env.asc.annDir='/att/gpfsfs/atrepo01/data/ORNL/ABoVE_Archive/datapool.asf.alaska.edu/METADATA/UA';
    env.asc.parProfile='local'; %'LocalProfile1- EK-ASC';
else
    env.asc.annDir='';
end
env.paths.topotoolbox='/home/ekyzivat/scripts/topotoolbox';
%% Load env? 
if load_env 
    uiopen('F:\PAD2019\classification_training\PixelClassifier\*.mat')
    env=model.env;
else
    
%% Image I/O and viewing params
    if isunix % on ASC
           % addpath
        addpath /att/gpfsfs/home/ekyzivat/scripts/random-wetlands/dnafinder-Cohen-a2b974e
        addpath /att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork
        addpath /att/gpfsfs/home/ekyzivat/scripts/random-wetlands
        env.output.test_dir=[env.output.cls_dir_asc, filesep, 'Test', env.run, '/'];
        env.bulk_plot_dir='/dev/null/';

            % viewing image dir
        env.viewingImageDir='/att/nobackup/ekyzivat/UAVSAR/Georeferenced/'; % optional

            % temp
        env.tempDir='/att/nobackup/ekyzivat/PixelClassifierTemp/';
    else % on local 
            % training file output directory
        env.output.train_dir=[env.output.cls_dir_local, filesep, 'Train', env.run, '\'];
        env.output.test_dir=[env.output.cls_dir_local, filesep, 'Test', env.run, '\'];
            
            % plotting
        env.bulk_plot_dir='D:\pic\UAVSAR_classification\';
        
            % viewing image dir
        env.viewingImageDir='F:\UAVSAR\Georeferenced\'; % optional
        
            % temp           
        env.tempDir='F:\PAD2019\classification_training\PixelClassifierTemp\';
    end
%% Parse input runfile
    
    if isunix
        csv_in=['/att/gpfsfs/home/ekyzivat/scripts/random-wetlands' filesep, 'run_inputs', filesep, 'run_inputs.csv'];
    else
        csv_in=['D:\Dropbox\Matlab\ABoVE\UAVSAR' filesep, 'run_inputs', filesep, 'run_inputs.csv'];
        warning(['CSV in is from:', csv_in])
    end
    csv=readtable(csv_in);
%     csv(1:end-1,:); % delete last info row
    xls.data=table2struct(csv);   
    env.input=xls.data;
    for n=1:size(xls.data,1)
%         env.input(n).cls_pth=env.class_dir
        env.input(n).bb         =   [xls.data(n).bb_xmin, xls.data(n).bb_ymin,...
            xls.data(n).bb_xmax, xls.data(n).bb_ymax];
        
%         % text arguments that are system-dependent
        if ~isunix %local
            env.input(n).im_dir    =   env.input(n).im_dir_local;
%             env.input(n).cls_pth   =   env.input(n).cls_pth_local;
            env.input(n).cls_pth   = [env.class_dir_local, '\', xls.data(n).cls_name];
            if isempty(env.input(n).im_dir) % if I didn't specifiy
                env.input(n).im_dir=  ['F:\UAVSAR\',...
                    env.input(n).name, filesep];
            end
        else %ASC
            env.input(n).cls_pth   = [env.class_dir_asc, '/', xls.data(n).cls_name];
            if isempty(env.input(n).im_dir) % if I didn't specifiy
                env.input(n).im_dir=  ['/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/',...
                env.input(n).name, filesep];
            end

        end
    end
    
        % model I/O (todo: add smart suffix automatically to avoid overwrite)
    env.output.current_model=[env.output.test_dir, 'model.mat'];
    env.output.current_training=[env.output.test_dir, 'training.mat'];
%     env.viewFileNums=[4];
%% classification training params % tag: common
    env.pixelClassifier.use_raw_image=1;
    env.pixelClassifier.sigmas=[]; %[1 2 3];
    % basic image features are simply derivatives (up to second order) in different scales;
    % this parameter specifies such scales (radius of offset); details in imageFeatures.m
    % for moving gaussian filter
    % each creates 9 features
    env.pixelClassifier.offsets=[3]; %[3 5]; %OPTIONAL,
    % in pixels; for offset features (see imageFeatures.m)
    % each creates 8 ->2 features
    % set to [] to ignore offset features
    env.pixelClassifier.osSigma = [2]; %2;
    % sigma for offset features (std dev of gaussian used for filter)
    env.pixelClassifier.radii = [];%[15 20 25]; %OPTIONAL
    % range of radii on which to compute circularity features (see imageFeatures.m)
    % set to [] to ignore circularity features
    env.pixelClassifier.cfSigma = []; %2;
    % sigma for circularity features
    env.pixelClassifier.logSigmas = [];%[1 2]; %OPTIONAL
    % sigmas for LoG features (see imageFeatures.m)
    % set to [] to ignore LoG features
    env.pixelClassifier.sfSigmas = [];%[1 2]; %OPTIONAL
    % steerable filter features sigmas (see imageFeatures.m)
    % set to [] to ignore steerable filter features
    % ridge (or edge) detection
    env.pixelClassifier.nTrees = 40; %20;
    % number of decision trees in the random forest ensemble
    env.pixelClassifier.minLeafSize = 30; %60;
    % minimum number of observations per tree leaf
    env.pixelClassifier.pctMaxNPixelsPerLabel = 5; % [1]; % unimportant- I'm way below limit
    % percentage of max number of pixels per label (w.r.t. num of pixels in image);
    % this puts a cap on the number of training samples and can improve training speed
    env.pixelClassifier.textureWindows=[5];
    % size of moving window to compute moving std dev
    env.pixelClassifier.speckleFilter=[1];
    % whether to use diffuse filter (replace with lee refined, if
    % desired...)
    env.pixelClassifier.gradient_smooth_kernel=[]; %7;
    % if > 0, computes max gradient (slope) in 8 directions of DEM band,
    % smoothing with a kernel of gradient_smooth_kernel
    env.pixelClassifier.tpi_kernel=[]; %7;
    % if > 0 , computes the TPI-topographic position index- using kernel
    % size tpi_kernel
%% classification params

    env.pixelClassifier.run.outputMasks = false;
    % if to output binary masks corresponding to pixel classes
    env.pixelClassifier.run.outputProbMaps = false;
    % if to output probability maps from which output masks are derived
    env.pixelClassifier.run.nSubsets = 64; %[50];
    % the set of pixels to be classified is split in this many subsets;
    % if nSubsets > 1, the subsets are classified using 'parfor' with
    % the currently-opened parallel pool (or a new default one if none is open);
    % see imClassify.m for details;
    % it's recommended to set nSubsets > the number of cores in the parallel pool;
    % this can make classification substantially faster than when a
    % single thread is used (nSubsets = 1).  Divides image into nSubsets
    % parts to classify, so numel(F)/nSubsets should fit into memory


    % stacked images output

%     env.inputType='Freeman-inc'; % DONT FORGET to change line 105 in
%     pixelClassifierTrain.m and line 61 in PixelClassifier... to update input Type
    
    % constants
    env.constants.imCenter=43; % 49.3 for YF-21508 (used for simple range correction)
    env.constants.n=0.5; %1.64; % range correction exponent
    env.constants.noDataValue=-10000; %-10000;
    env.constants.noDataValue_ouput=0;
%% classes
        % set order of classes (defines numerical index, which will be written
        % to meta file)
    env.class_names={'OW', 'WS', 'WH', 'SB', 'WG', 'DG',...
        'DS', 'DF', 'BS', 'DW', 'RW', 'BG', 'WF'}; %{'W1', 'GW', 'GD', 'SW', 'SD', 'FD'}; %, 'TD', 'TW'}; % {'W1', 'W2', 'EU', 'BG', 'HW', 'GW', 'GD', 'SW', 'SD', 'FW', 'FD'}, no BG; {'W1', 'W2', 'BG', 'HW', 'GW', 'GD', 'SW', 'SD', 'FD'}; % < prior to  Dec 2  
%     env.class_names={'W1', 'SW', 'HW', 'BA', 'GW', 'GD',...
%         'SD', 'FD', 'FD2', 'WD', 'W2', 'BG', 'FW'}; %{'W1', 'GW', 'GD', 'SW', 'SD', 'FD'}; %, 'TD', 'TW'}; % {'W1', 'W2', 'EU', 'BG', 'HW', 'GW', 'GD', 'SW', 'SD', 'FW', 'FD'}, no BG; {'W1', 'W2', 'BG', 'HW', 'GW', 'GD', 'SW', 'SD', 'FD'}; % < prior to  Dec 2  
%     env.class_names={'W1', 'GW', 'GD', 'SW', 'SD', 'FD'};
    env.class_names_full={'Water', 'Graminoid Wet','Graminoid Dry', 'Shrub Wet', 'Shrub Dry', 'Forest Dry'};
%% colors
    env.plot.colors_hex={'BED2FF', '58D918','FFC861','31780D','BF9649','8ACC34'};% NEED to fix color-blindness {'BED2FF','A80000','E69800','38A800', 'A87000', '732600'};
    if ~isunix
       for i=1:length(env.plot.colors_hex)
           env.plot.colors{i}=hex2rgb(env.plot.colors_hex{i});
           env.plot.colors_mat(i,:)=hex2rgb(env.plot.colors_hex{i});
           env.plot.colors_8bit{i}=255*hex2rgb(env.plot.colors_hex{i});
       end
    end
    
%% plots
    if env.use_inc_band && isnan(env.dem_band) % if inc band exists
        env.plot.bandLabels={'Double','Volume', 'Single', 'Range'};
    elseif isnan(env.inc_band) && ~isnan(env.dem_band)
        env.plot.bandLabels={'HH', 'HV', 'VV','DEM'};
    else
        env.plot.bandLabels={'Double','Volume', 'Single'};
    end
%% validition set partitioning
    env.valPartitionRatio=0.15; % what percentage held back for validation % NOT inverse of ratio between no of training and total (= training + val) pixels
    env.seed=22; % random number gen seed!  
%% proj source
    
    if ~isunix
        env.proj_source='F:\UAVSAR\Georeferenced\proj\102001.prj';
    else
        env.proj_source='/att/gpfsfs/home/ekyzivat/scripts/proj/102001.prj';
    end
end
%% acknowledgements
% matlab file exchange ENVI read/write
%matlab file exchange/github PixelClassifier
% file exhange hex2rgb https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb
% caputre figure vid: https://www.mathworks.com/matlabcentral/fileexchange/41093-create-video-of-rotating-3d-plot