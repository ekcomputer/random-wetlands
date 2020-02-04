% env vars for running pixel classifier
clear env
global env
load_env=0; % load env. from previous run?
if load_env 
    uiopen('F:\PAD2019\classification_training\PixelClassifier\*.mat')
    env=model.env;
else
    
    %% Image I/O and viewing params
env.trainingClassRasters=0; % set to 1 to make training class rasters; 0 for viewing image only


    if ~isunix
                % training file output directory
        env.output.train_dir='F:\PAD2019\classification_training\PixelClassifier\Train23\';
        % env.output.train_dir='F:\PAD2019\classification_training\PixelClassifier\Train_origClass\Train';
        env.output.test_dir='F:\PAD2019\classification_training\PixelClassifier\Test23\';
        % env.output.val_dir='F:\PAD2019\classification_training\PixelClassifier\Validation\';
        % env.output.current_model='F:\PAD2019\classification_training\PixelClassifier\model5.mat';
        % where the model is
        % where images are
            % Which files to import as training images
        env.trainFileNums=[2]; % [1 2]
            % plotting
        env.bulk_plot_dir='D:\pic\UAVSAR_classification\';

            % viewing image dir
        env.viewingImageDir='F:\UAVSAR\Georeferenced\'; % optional

            % temp
            
        env.tempDir='F:\PAD2019\classification_training\PixelClassifierTemp\';

            % training image and classes input and bounding boxes
        env.input(1).im_dir=        'F:\UAVSAR\padelE_36000_18047_000_180821_L090_CX_01\';
        env.input(1).cls_pth=       'F:\PAD2019\classification_training\training2018PAD_Jan28_allClasses.shp';
        env.input(1).name=          'padelE_36000_18047_000_180821_L090_CX_01';
        env.input(1).bb=            [];%[-111.913 58.323 -110.894 58.99]; %xmin ymin xmax ymax

        env.input(2).im_dir=        'F:\UAVSAR\padelE_36000_19059_003_190904_L090_CX_01\';
        % env.input(2).cls_pth=       'F:\PAD2019\classification_training\training2019PAD.shp';
        env.input(2).cls_pth=       'F:\PAD2019\classification_training\training2019PAD_Jan28_allClasses.shp';% dummy for bounding box only
        env.input(2).name=          'padelE_36000_19059_003_190904_L090_CX_01';
        env.input(2).bb=            [];%[-111.913 58.323 -110.894 58.99]; 

        env.input(3).im_dir=        'F:\UAVSAR\PADELT_36000_17062_003_170613_L090_CX_01\';
        env.input(3).cls_pth=       'F:\PAD2019\classification_training\training2019PAD_Jan01_allClasses.shp';% dummy for bounding box only
        env.input(3).name=          'PADELT_36000_17062_003_170613_L090_CX_01'; 
        env.input(3).bb=            [];%[-107.128 52.586]; 
        
        env.input(4).im_dir=        'F:\UAVSAR\padelE_36000_17093_007_170908_L090_CX_01\';
        env.input(4).cls_pth=       'F:\PAD2019\classification_training\training2019PAD_Jan01_allClasses.shp';
        env.input(4).name=          'padelE_36000_17093_007_170908_L090_CX_01';
        env.input(4).bb=            [];%[-107.128 52.586]; 
        
        env.input(5).im_dir=        'F:\UAVSAR\redber_30704_17092_000_170907_L090_CX_01\Pout\';
        env.input(5).cls_pth=       '';
        env.input(5).name=          'redber_30704_17092_000_170907_L090_CX_01';
        env.input(5).bb=            [];%[-107.128 52.586]; 

        env.input(6).im_dir=        'F:\UAVSAR\PADELT_36000_17062_003_170613_L090_CX_01\';
        env.input(6).cls_pth=       '';
        env.input(6).name=          'PADELT_36000_17062_003_170613_L090_CX_01';
        env.input(6).bb=            [];%[-107.128 52.586]; 

        env.input(7).im_dir=        'F:\UAVSAR\yflats_21609_17069_011_170621_L090_CX_01\';
        env.input(7).cls_pth=       ''; %FILL
        env.input(7).name=          'yflats_21609_17069_011_170621_L090_CX_01';
        env.input(7).bb=            [];

    else % on ASC cloud / unix
            % addpath
        addpath /att/gpfsfs/home/ekyzivat/scripts/random-wetlands/dnafinder-Cohen-a2b974e
        addpath /att/gpfsfs/home/ekyzivat/scripts/PixelClassifier-fork
        addpath /att/gpfsfs/home/ekyzivat/scripts/random-wetlands
        env.trainFileNums=[8]; % [1 2]
        env.output.train_dir='/att/nobackup/ekyzivat/PixelClassifier/Train21_2/';
        env.output.test_dir='/att/nobackup/ekyzivat/PixelClassifier/Test21_2/';
        env.bulk_plot_dir='/dev/null/';

            % viewing image dir
        env.viewingImageDir='/att/nobackup/ekyzivat/UAVSAR/Georeferenced/'; % optional

            % temp
        env.tempDir='/att/nobackup/ekyzivat/PixelClassifierTemp/';

            % training image and classes input and bounding boxes
        env.input(1).im_dir=        '/att/nobackup/ekyzivat/UAVSAR/padelE_36000_18047_000_180821_L090_CX_01/';
        env.input(1).cls_pth=       '';%'F:\PAD2019\classification_training\training2018PAD.shp';
        env.input(1).name=          'padelE_36000_18047_000_180821_L090_CX_01';

        env.input(2).im_dir=        '/att/nobackup/ekyzivat/UAVSAR/padelE_36000_19059_003_190904_L090_CX_01/';
        env.input(2).cls_pth=       '';%'F:\PAD2019\classification_training\training2018PAD.shp';
        env.input(2).name=          'padelE_36000_19059_003_190904_L090_CX_01';
        
        env.input(8).im_dir=        '/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflats_21508_17069_009_170621_L090_CX_01/';
        env.input(8).cls_pth=       ''; %FILL
        env.input(8).name=          'yflats_21508_17069_009_170621_L090_CX_01';
        env.input(8).bb=            [-2062054 3722869 -1944050 3771023]; %[-2033247.02283896 3729820.83180865 -2017337.22173237 3742108.79560523]; % in Canada Albers coords gdal: xmin ymin xmax ymax
        
        env.input(9).im_dir=        '/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/yflatW_21508_17098_006_170916_L090_CX_01/';
        env.input(9).cls_pth=       ''; %FILL
        env.input(9).name=          'yflatW_21508_17098_006_170916_L090_CX_01';
        env.input(9).bb=            [-2062054 3722869 -1944050 3771023]; %-2033247.02283896 3729820.83180865 -2017337.22173237 3742108.79560523];
        
        env.input(10).im_dir=        '/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/bakerc_16008_18047_005_180821_L090_CX_02/';
        env.input(10).cls_pth=       ''; %FILL
        env.input(10).name=          'bakerc_16008_18047_005_180821_L090_CX_02';
        env.input(10).bb=            [-926392 2606036 -905775 2667020]; %-2033247.02283896 3729820.83180865 -2017337.22173237 3742108.79560523];

        env.input(11).im_dir=        '/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/bakerc_16008_19059_012_190904_L090_CX_01/';
        env.input(11).cls_pth=       ''; %FILL
        env.input(11).name=          'bakerc_16008_19059_012_190904_L090_CX_01';
        env.input(11).bb=            [-926392 2606036 -905775 2667020]; %-2033247.02283896 3729820.83180865 -2017337.22173237 3742108.79560523];

        env.input(12).im_dir=        '/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/bakerc_16008_19059_012_190904_L090_CX_01/';
        env.input(12).cls_pth=       ''; %FILL
        env.input(12).name=          'bakerc_16008_19059_012_190904_L090_CX_01';
        env.input(12).bb=            [-926392 2606036 -905775 2667020]; %-2033247.02283896 3729820.83180865 -2017337.22173237 3742108.79560523];
        
        env.input(13).im_dir=        '/att/nobackup/ekyzivat/UAVSAR/asf.alaska.edu/bakerc_16008_19059_012_190904_L090_CX_01/';
        env.input(13).cls_pth=       ''; %FILL
        env.input(13).name=          'bakerc_16008_19059_012_190904_L090_CX_01';
        env.input(13).bb=            [-926392 2606036 -905775 2667020]; %-2033247.02283896 3729820.83180865 -2017337.22173237 3742108.79560523];
        
        
        
        % 
%         env.input(9).im_dir=        '';
%         env.input(9).cls_pth=       ''; %FILL
%         env.input(9).name=          'yflatW_21508_17098_006_170916_L090_CX_01';
%         env.input(9).bb=            [[]; %-2033247.02283896 3729820.83180865 -2017337.22173237 3742108.79560523];
% 
%         env.input(9).im_dir=        '';
%         env.input(9).cls_pth=       ''; %FILL
%         env.input(9).name=          'yflatW_21508_17098_006_170916_L090_CX_01';
%         env.input(9).bb=            [[]; %-2033247.02283896 3729820.83180865 -2017337.22173237 3742108.79560523];

    end

        % model I/O (todo: add smart suffix automatically to avoid overwrite)
    env.output.current_model=[env.output.test_dir, 'model.mat'];
%     env.viewFileNums=[4];
    %% classification training params
    env.pixelClassifier.use_raw_image=1;
    env.pixelClassifier.sigmas=[]; %[1 2 3];
    % basic image features are simply derivatives (up to second order) in different scales;
    % this parameter specifies such scales (radius of offset); details in imageFeatures.m
    % for moving gaussian filter
    % each creates 9 features
    env.pixelClassifier.offsets=[3]; %[3 5]; %OPTIONAL,
    % in pixels; for offset features (see imageFeatures.m)
    % each creates 8 features
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
    env.pixelClassifier.minLeafSize = 40; %60;
    % minimum number of observations per tree leaf
    env.pixelClassifier.pctMaxNPixelsPerLabel = 5; % [1]; % unimportant- I'm way below limit
    % percentage of max number of pixels per label (w.r.t. num of pixels in image);
    % this puts a cap on the number of training samples and can improve training speed
    env.pixelClassifier.textureWindows=[5];
    % size of moving window to compute moving std dev
    
    env.pixelClassifier.speckleFilter=[1];
    % whether to use diffuse filter (replace with lee refined, if
    % desired...)
    %% classification params

    env.pixelClassifier.run.outputMasks = true;
    % if to output binary masks corresponding to pixel classes
    env.pixelClassifier.run.outputProbMaps = false;
    % if to output probability maps from which output masks are derived
    env.pixelClassifier.run.nSubsets = 25; %[50];
    % the set of pixels to be classified is split in this many subsets;
    % if nSubsets > 1, the subsets are classified using 'parfor' with
    % the currently-opened parallel pool (or a new default one if none is open);
    % see imClassify.m for details;
    % it's recommended to set nSubsets > the number of cores in the parallel pool;
    % this can make classification substantially faster than when a
    % single thread is used (nSubsets = 1).  Divides image into nSubsets
    % parts to classify, so numel(F)/nSubsets should fit into memory


    % stacked images output

    % which input images

    env.inputType='Freeman-inc'; %'Freeman', 'C3', 'Freeman-T3' or 'gray', 'Freeman-inc', 'C3-inc'
%     env.inputType='Freeman-inc'; % DONT FORGET to change line 105 in
%     pixelClassifierTrain.m and line 61 in PixelClassifier... to update input Type
    env.rangeCorrection=1;
    
    % constands
    env.constants.imCenter=43; % 49.3 for YF-21508
    env.constants.n=0.5; %1.64; % range correction exponent
    env.constants.noDataValue=-10000;
    env.constants.noDataValue_ouput=0;



    %% classes
        % set order of classes (defines numerical index, which will be written
        % to meta file)
    env.class_names={'W1', 'SW', 'HW', 'TW', 'GW', 'GD', 'SD', 'FD', 'FD2', 'TD', 'W2'}; %{'W1', 'GW', 'GD', 'SW', 'SD', 'FD'}; %, 'TD', 'TW'}; % {'W1', 'W2', 'EU', 'BG', 'HW', 'GW', 'GD', 'SW', 'SD', 'FW', 'FD'}, no BG; {'W1', 'W2', 'BG', 'HW', 'GW', 'GD', 'SW', 'SD', 'FD'}; % < prior to  Dec 2  
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
    
    env.plot.bandLabels={'Double','Volume', 'Single', 'Range'};
    %% validition set partitioning
    env.valPartitionRatio=0.15; % what percentage held back for validation % NOT inverse of ratio between no of training and total (= training + val) pixels
    env.seed=22; % random number gen seed!
end
%% acknowledgements
% matlab file exchange ENVI read/write
%matlab file exchange/github PixelClassifier
% file exhange hex2rgb https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb
% caputre figure vid: https://www.mathworks.com/matlabcentral/fileexchange/41093-create-video-of-rotating-3d-plot