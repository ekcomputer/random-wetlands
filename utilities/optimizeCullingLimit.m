% run after pixelClassifierTrain
% look at ouptut structure to figure out effects of culling limit on
% Overall Accuracy (OA).

%% run this before culling, if 
% ft_all_sv=ft_all;
% lb_all_sv=lb_all;

%% begin
itr=0; % init
limits=[logspace(2,5,5), 3e5]; % where 3e5 is greater than max (2.16 e5) so is equiv. to using inf as max
for limit= limits
    itr=itr+1;
    fprintf('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')
    fprintf('ITERATION: %d    ~~~~~~~~~~~~~~~~~~~~~~~~\n', itr)
    fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')
        %% initialize
    lb_all=lb_all_sv;
    ft_all=ft_all_sv;
    
    %% limit number of pixels for each training class (culling)
        % done after computing features and extracting labelled pixels

    if env.equalizeTrainClassSizes % culling
        fprintf('\nTraining set size equalization/culling.\n')
        f.limit=limit; % sloppy best guess for class size limit
    %     msk=ones(size(lb_all));
        for class=1:nLabels % loop over bands w/i image
            if f.counts(class) > f.limit
                msk=lb_all==class; % positive mask for each class, overwrites, can change dims as lb_all shrinks
                f.ratio=f.limit/f.counts(class); 
                fprintf('\tClass:  %s.\tFraction to keep:  %0.2f\n',env.class_names{class}, f.ratio)
                rng(111);
                f.c = cvpartition(int8(msk),'Holdout',f.ratio); % overwrites each time % f.c.testsize is far larger than f.limit, but it includes entries that weren't orig.==band
                lb_all(f.c.training & msk)=[]; % set extra px equal to zero for large classe
                ft_all(f.c.training & msk, :)=[]; % new 3/30/2020

                    % uncomment to check that new features from a class were part of original class....
    %             all(ismember(ft_all(lb_all==class,:), ft_all_sv(lb_all_sv==class,:)))
            end
        end
    end

    %%
        % Re-display equilization data
    f.counts_afterEq=histcounts(lb_all, 0.5:nLabels+0.5);
    f.countsTable_after=table(env.class_names', f.counts, f.counts_afterEq', 'VariableNames', {'Class','TrainingPxOld', 'TrainingPxNew'});
    fprintf('Modified table of training pixel counts:\n')
    fprintf('( Equalize training class sizes is set to:\t%d )\n\n', env.equalizeTrainClassSizes)
    disp(f.countsTable_after)
    if 1==0 % for testing
        histogram('Categories', env.class_names, 'BinCounts', f.counts_afterEq)
    end

    %% split into training and val datasets; turn labels into categories
        % lb and ft are training partitions, lb_val and ft_val are validation
        % partitions, lb_all and ft_all include both
    global env
    rng(env.seed);
    c = cvpartition(lb_all,'Holdout',env.valPartitionRatio);
    for p=1:length(lb_all)
        lb_all_cell{p}=sprintf('%02d-%s',lb_all(p), env.class_names{lb_all(p)});
    end
    ft=ft_all(c.training(1),:);
    lb=lb_all_cell(c.training(1));
    ft_subset_validation=ft_all(c.test(1),:);
    lb_subset_validation=lb_all_cell(c.test(1));

    %% print band stats for each training class (using all data, not just training split)
    % lb=lb_all_cell(c.training(1));
    % f.trainTable=array2table([lb, ft]);
    % grpstats()

    fprintf('Checking that training classes have valid data:\n')
    for class=1:nLabels
        f.percentValidTmp=100*sum(ft_all(:,1)>0 & lb_all == class)/sum(lb_all == class);
        fprintf('\tClass: %s.\tPercent of feature 1 > 0:  %0.2f%%\n',env.class_names{class}, f.percentValidTmp)
        if f.percentValidTmp < 99
           warning('Some invalid pixels are present in the training data.') 
        end
    end
    %% training

    fprintf('training...\n'); tic
    % rng('shuffle')
    [treeBag,featImp,oobPredError] = rfTrain(ft,lb,nTrees,minLeafSize, env.seed);
    figureQSS
    subplot(1,2,1), 
    if strcmp(env.inputType, 'Freeman-inc')
    %     featImp=[featImp, zeros(1, length(featNames)*nBands-length(featImp))]; 
        featImp=[featImp, zeros(1, length(featNames)-2)]; 
    elseif strcmp(env.inputType, 'C3-inc')
    %     featImp=[featImp, zeros(1, length(featNames)*nBands-length(featImp))]; 
        featImp=[featImp, zeros(1, length(featNames)-2)]; %%HERE TODO
    else
    end
    featImpRshp=reshape(featImp, [length(featImp)/nBands, nBands ]); %% <----HERE
    barh(featImpRshp), set(gca,'yticklabel',featNames'), set(gca,'YTick',1:length(featNames)), title('feature importance')
    legend_txt=env.plot.bandLabels;
    % legend_txt=cellstr(num2str([1:nBands]'));
    legend(legend_txt, 'Location', 'best', 'FontSize', 12);
    subplot(1,2,2), plot(oobPredError), title('out-of-bag classification error')
    fprintf('training time: %f s\n', toc);

    %% validation: confusion matrix on only test subset of image
        % reconstruct F
    % F=cat(3, F{1}, F{2}, F{3});
    % imL = imClassify(F,treeBag,1);
    try
        [~,scores] = predict(treeBag,ft_subset_validation); % can use ft_all, but that might be cheating; ft_val is a k-fold subset
        [~,lb_val_test] = max(scores,[],2);
        clear lb_val_test_cell
        for p=1:length(lb_val_test)
            lb_val_test_cell{p}=sprintf('%02d-%s',lb_val_test(p), env.class_names{lb_val_test(p)});
        end
        [v.C, v.cm, v.order, v.k, v.OA]=confusionmatStats(lb_subset_validation,lb_val_test_cell, env.class_names);
    catch
        warning('Confusion matrix stats failed at some point.')
    end
    
    %% save model
    model.treeBag = treeBag;
    model.sigmas = sigmas;
    model.offsets = offsets;
    model.osSigma = osSigma;
    model.radii = radii;
    model.cfSigma = cfSigma;
    model.logSigmas = logSigmas;
    model.sfSigmas = sfSigmas;
    model.oobPredError=oobPredError;
    model.featImp=featImp;
    model.featNames=featNames;
    model.use_raw_image=use_raw_image;
    model.textureWindows=textureWindows;
    model.speckleFilter=speckleFilter;
    model.validation=v;
    model.env=env;
    
    output(itr).model=model;
    output(itr).ft_all=ft_all;
    output(itr).lb_all=lb_all;
end

%% plot summary stats
figure;
% py=[output.model.validation.k];
px=limits;
py=[0.73 0.83 0.92 0.94 0.95]; % manual
plot(px, py)
xlabel('Max number of training samples / class')
ylabel('Kappa coefficient')