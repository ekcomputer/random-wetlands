% env vars for running pixel classifier
clear env
global env
load_env=0; % load env. from previous run?
if load_env 
    uiopen('F:\PAD2019\classification_training\PixelClassifier\*.mat')
    env=model.env;
else
    
    %% Image I/O and viewing params


    if ~isunix
                % training file output directory
        env.output.train_dir='F:\PAD2019\classification_training\PixelClassifier\Train17\';
        % env.output.train_dir='F:\PAD2019\classification_training\PixelClassifier\Train_origClass\Train';
        env.output.test_dir='F:\PAD2019\classification_training\PixelClassifier\Test17\';
        % env.output.val_dir='F:\PAD2019\classification_training\PixelClassifier\Validation\';
        % env.output.current_model='F:\PAD2019\classification_training\PixelClassifier\model5.mat';
        % where the model is
        % where images are

            % plotting
        env.bulk_plot_dir=          'D:\pic\UAVSAR_classification\';

            % viewing image dir
        env.viewingImageDir='F:\UAVSAR\Georeferenced\'; % optional

            % temp
            
        env.tempDir='F:\PAD2019\classification_training\PixelClassifierTemp\';

            % training image and classes input and bounding boxes
        env.input(1).im_dir=        'F:\UAVSAR\padelE_36000_18047_000_180821_L090_CX_01\';
        env.input(1).cls_pth=       'F:\PAD2019\classification_training\training2018PAD.shp';
        env.input(1).name=          'padelE_36000_18047_000_180821_L090_CX_01';
        env.input(1).bb=            [];%[-111.913 58.323 -110.894 58.99]; %xmin ymin xmax ymax

        env.input(2).im_dir=        'F:\UAVSAR\padelE_36000_19059_003_190904_L090_CX_01\';
        % env.input(2).cls_pth=       'F:\PAD2019\classification_training\training2019PAD.shp';
        env.input(2).cls_pth=       'F:\PAD2019\classification_training\training2019PAD_CHECKPOINTDec5.shp';
        env.input(2).name=          'padelE_36000_19059_003_190904_L090_CX_01';
        env.input(2).bb=            [];%[-111.913 58.323 -110.894 58.99]; 

        env.input(3).im_dir=        'F:\UAVSAR\redber_30704_17092_000_170907_L090_CX_01\Pout\';
        env.input(3).cls_pth=       '';
        env.input(3).name=          'redber_30704_17092_000_170907_L090_CX_01';
        env.input(3).bb=            [];%[-107.128 52.586]; 

        env.input(4).im_dir=        'F:\UAVSAR\PADELT_36000_17062_003_170613_L090_CX_01\';
        env.input(4).cls_pth=       '';
        env.input(4).name=          'PADELT_36000_17062_003_170613_L090_CX_01';
        env.input(4).bb=            [];%[-107.128 52.586]; 

        env.input(5).im_dir=        'F:\UAVSAR\yflats_21609_17069_011_170621_L090_CX_01\';
        env.input(5).cls_pth=       ''; %FILL
        env.input(5).name=          'yflats_21609_17069_011_170621_L090_CX_01';
        env.input(5).bb=            [];

        env.input(5).im_dir=        'F:\UAVSAR\yflats_21609_17069_011_170621_L090_CX_01\';
        env.input(5).cls_pth=       ''; %FILL
        env.input(5).name=          'yflats_21609_17069_011_170621_L090_CX_01';
        env.input(5).bb=            [];

    else
            % addpath
        addpath /att/gpfsfs/home/ekyzivat/scripts/random-wetlands/dnafinder-Cohen-a2b974e

        env.output.train_dir='/att/nobackup/ekyzivat/PixelClassifier/Train/';
        env.output.test_dir='/att/nobackup/ekyzivat/PixelClassifier/Test17/';
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
    end

        % model I/O (todo: add smart suffix automatically to avoid overwrite)
    env.output.current_model=[env.output.test_dir, 'model.mat'];
    env.trainFileNums=[1 2]; % [1 2]
    env.viewFileNums=[4];
    %% classification training params
    env.pixelClassifier.use_raw_image=1;
    env.pixelClassifier.sigmas=[1]; %[1 2 3];
    % basic image features are simply derivatives (up to second order) in different scales;
    % this parameter specifies such scales; details in imageFeatures.m
    % for moving gaussian filter
    % each creates 9 features
    env.pixelClassifier.offsets=[]; %[3 5]; %OPTIONAL,
    % in pixels; for offset features (see imageFeatures.m)
    % each creates 8 features
    % set to [] to ignore offset features
    env.pixelClassifier.osSigma = []; %2;
    % sigma for offset features (std dev of gaussian used for filter)
    env.pixelClassifier.radii = [];%[15 20 25]; %OPTIONAL
    % range of radii on which to compute circularity features (see imageFeatures.m)
    % set to [] to ignore circularity features
    env.pixelClassifier.cfSigma = []; %2;
    % sigma for circularity features
    env.pixelClassifier.logSigmas = [1];%[1 2]; %OPTIONAL
    % sigmas for LoG features (see imageFeatures.m)
    % set to [] to ignore LoG features
    env.pixelClassifier.sfSigmas = [1];%[1 2]; %OPTIONAL
    % steerable filter features sigmas (see imageFeatures.m)
    % set to [] to ignore steerable filter features
    % ridge (or edge) detection
    env.pixelClassifier.nTrees = 35; %20;
    % number of decision trees in the random forest ensemble
    env.pixelClassifier.minLeafSize = 40; %60;
    % minimum number of observations per tree leaf
    env.pixelClassifier.pctMaxNPixelsPerLabel = 1; % unimportant- I'm way below limit
    % percentage of max number of pixels per label (w.r.t. num of pixels in image);
    % this puts a cap on the number of training samples and can improve training speed
    env.pixelClassifier.textureWindows=[3 9];
    % size of moving window to compute moving std dev
    %% classification params

    env.pixelClassifier.run.outputMasks = true;
    % if to output binary masks corresponding to pixel classes
    env.pixelClassifier.run.outputProbMaps = false;
    % if to output probability maps from which output masks are derived
    env.pixelClassifier.run.nSubsets = 100;
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

    env.inputType='Freeman'; %'Freeman', 'C3', 'Freeman-T3' or 'gray'




    %% classes
        % set order of classes (defines numerical index, which will be written
        % to meta file)
    env.class_names={'W1', 'GW', 'GD', 'SW', 'SD', 'FD'}; %, 'TD', 'TW'}; % {'W1', 'W2', 'EU', 'BG', 'HW', 'GW', 'GD', 'SW', 'SD', 'FW', 'FD'}, no BG; {'W1', 'W2', 'BG', 'HW', 'GW', 'GD', 'SW', 'SD', 'FD'}; % < prior to  Dec 2  
    env.class_names_full={'Water', 'Graminoid Wet','Graminoid Dry', 'Shrub Wet', 'Shrub Dry', 'Forest Dry'};

    %% colors
    env.plot.colors_hex={'BED2FF','A80000','E69800','38A800', 'A87000', '732600'};
    if ~isunix
       for i=1:length(env.plot.colors_hex)
           env.plot.colors{i}=hex2rgb(env.plot.colors_hex{i});
           env.plot.colors_8bit{i}=255*hex2rgb(env.plot.colors_hex{i});
       end
    end
    %% validition set partitioning
    env.valPartitionRatio=6; % inverse of ratio between no of training and total (= training + val) pixels
    env.seed=22; % random number gen seed!
end
%% acknowledgements
% matlab file exchange ENVI read/write
%matlab file exchange/github PixelClassifier
% file exhange hex2rgb https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb
% caputre figure vid: https://www.mathworks.com/matlabcentral/fileexchange/41093-create-video-of-rotating-3d-plot