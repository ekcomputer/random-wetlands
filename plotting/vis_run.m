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
base='F:\PAD2019\classification_training\PixelClassifier\Test32';
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
try
    numDEMFeats=length(horzcat(env.pixelClassifier.gradient_smooth_kernel, env.pixelClassifier.tpi_kernel));
catch
    numDEMFeats=0;
end
if contains(env.inputType, {'-inc'})
    numRadarFeats=length(featNames)-1-numDEMFeats;
else
    numRadarFeats=length(featNames)-numDEMFeats;
end

if isnan(env.dem_band) %xor(isnan(env.inc_band), isnan(env.dem_band)) % ismember(env.inputType, {'Freeman', 'C3', 'T3'})
%     featImp=[featImp, zeros(1, length(featNames)*nBands-length(featImp))]; 
    featImpTemp=zeros(1, nBandsFinal*numRadarFeats);
    featImpTemp(1:length(featImp))=featImp;
    featImpRshp=reshape(featImpTemp, [numRadarFeats, nBandsFinal ]);
%     featImp=[featImp, zeros(1, length(featNames)-2)]; 
else  % if using dem bands
    featImpTemp=zeros(1, nBandsFinal*length(featNames));
    featImpRshp=reshape(featImpTemp, [length(featNames), nBandsFinal ]);
    for band = 1:nBandsFinal
        if ismember(band, env.radar_bands)
            featImpRshp(1:numRadarFeats,band)=...
                featImp((band-1)*numRadarFeats+1:(band)*numRadarFeats);
        elseif ismember(band, env.dem_band)
            featImpRshp(end-numDEMFeats+1:end,band)=...
                featImp(end-numDEMFeats+1:end);
        else
            error('not defined')
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

barh(featImpRshp), set(gca,'yticklabel',featNames'), set(gca,'YTick',1:length(featNames)), title('Feature importance')
legend_txt=env.plot.bandLabels;
% legend_txt=cellstr(num2str([1:nBands]'));
legend(legend_txt, 'Location', 'best', 'FontSize', 12);
subplot(1,2,2), plot(oobPredError), title('OOB classification error')

%% confusion matrix
[v.C, v.cm, v.order, v.k, v.OA]=confusionmatStats(lb_subset_validation,lb_val_test_cell, env.class_names);

%% alt CM stats
fprintf('\n~~~~~~~~~~~~~~~~~~~~~~~~~~\nFinal OOB error: %0.3f\n', oobPredError(end))

%% plot features and class boundaries
viewClassCentroids;


%% Plot inc info


