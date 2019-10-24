% env vars for running pixel classifier
clear env
global env

% training image and classes input
env.bulk_plot_dir='D:\pic\UAVSAR_classification\'
env.input(1).im_dir='F:\UAVSAR\padelE_36000_18047_000_180821_L090_CX_01\sub1k2k\';
env.input(1).cls_pth='F:\PAD2019\classification_training\training2018PAD.shp';
env.input(1).name='padelE_36000_18047_000_180821_L090_CX_01';
env.input(2).im_dir='';
env.input(2).cls_pth='F:\PAD2019\classification_training\training2018PAD.shp';

env.output.train_dir='F:\PAD2019\classification_training\PixelClassifier\Train\';

% stacked images output

% which input images

env.inputType='Freeman'; %'Freeman', 'C3', or 'gray'

% temp
env.tempDir='F:\PAD2019\classification_training\PixelClassifierTemp\';

% model I/O (todo: add smart suffix automatically to avoid overwrite)
env.current_model='F:\PAD2019\classification_training\PixelClassifier\model2.mat';

% classes

env.class_names={'W1', 'W2', 'EU', 'BG', 'HW', 'GW', 'GD', 'SW', 'SD', 'FW', 'FD'};

% bounding boxes
env.input(1).bb=

%% acknowledgements
% matlab file exchange ENVI read/write
%matlab file exchange/github PixelClassifier