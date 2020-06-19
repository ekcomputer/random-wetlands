% A script to create summary images after classification run

% Inputs:       model_pth:      path to model (e.g. 'model.m')
%               training_pth:   path to training data (e.g. 'training.m') %
%               can also be loaded from model.treeBag...
%
% Outputs:      plots confusion matrix, xclassification tree diagram, class
%               metrics, separability plots, more...?

%% I/O
clear
% Env_PixelClassifier
base='F:\PAD2019\classification_training\PixelClassifier\Test34';
model_pth = [base, '\model.mat'];
training_pth = [base, '\training.mat'];
load(model_pth); load(training_pth);
env=model.env;

%% Plot OOB and feature importance diagrams...

    % inputs
featImp=model.featImp;
featNames=model.featNames;
nBandsFinal=max([env.radar_bands, env.inc_band, env.dem_band]); %model.treeBag.NumPredictorsToSample;
oobPredError=model.oobPredError;

    % from pixelClassifierTrain.m:
figureQSS
subplot(1,2,1), 

%%%%%%%%%%%% modified%%%%%
if contains(env.inputType, {'-inc'})
    numRadarFeats=length(featNames)-1-length(horzcat(env.pixelClassifier.gradient_smooth_kernel, env.pixelClassifier.tpi_kernel));
else
    numRadarFeats=length(featNames)-length(horzcat(env.pixelClassifier.gradient_smooth_kernel, env.pixelClassifier.tpi_kernel));
end

% if xor(isnan(env.inc_band), isnan(env.dem_band)) % ismember(env.inputType, {'Freeman', 'C3', 'T3'})
%     featImp=[featImp, zeros(1, length(featNames)*nBands-length(featImp))]; 
    featImpTemp=zeros(1, nBandsFinal*numRadarFeats);
    featImpTemp(1:length(featImp))=featImp;
%     featImp=[featImp, zeros(1, length(featNames)-2)]; 
% else %same...
  
% end
featImpRshp=reshape(featImpTemp, [numRadarFeats, nBandsFinal ]); %% <----HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%

barh(featImpRshp), set(gca,'yticklabel',featNames'), set(gca,'YTick',1:length(featNames)), title('feature importance')
legend_txt=env.plot.bandLabels;
% legend_txt=cellstr(num2str([1:nBands]'));
legend(legend_txt, 'Location', 'best', 'FontSize', 12);
subplot(1,2,2), plot(oobPredError), title('out-of-bag classification error')

%% confusion matrix

    [v.C, v.cm, v.order, v.k, v.OA]=confusionmatStats(lb_subset_validation,lb_val_test_cell, env.class_names);

%% alt CM stats
%% Confusion Matrix plots

%% Plot inc info


