% script to plot machine-learning style visualization of class centroids
% run after pixelClassifierTrain (need F data structure) for 3 bands

% TODO: meshgrid a la: https://www.mathworks.com/help/stats/examples/classification.html
% TODO: log transform as its own variable

% Env_PixelClassifier;


%% I/O
PLOT_size_data=40; %110;
featOS=0; % Feature Offset (zero to use raw image, etc.)

%% reclassify
rng(env.seed); % simulate when model was trained
holdoutRatio=env.valPartitionRatio; % 0.09; % uncomment to use holdout in testing
holdout=cvpartition(lb_all, 'HoldOut', holdoutRatio); % uncomment for testing
ft_plot=ft_all(holdout.training,:); % uncomment for testing
lb_plot=lb_all(holdout.training,:); % uncomment for testing
    % reclassify - uncomment
% lb_plot(ismember(lb_all, [1 2 3]))=3;
% ft_plot(ismember(lb_all, [1 2 3]))=3;
% lb_plot=lb_plot-2;
% ft_plot=ft_plot-2;

%% plot
a=0.15; % alpha value
if strcmp(env.inputType, 'Freeman-inc')
    max_idx=size(ft_plot,2)-1;
    skip_idx=length(featNames)-1;
else
    max_idx=size(ft_plot,2);
    skip_idx=length(featNames);
end
figure; 
clf; hold on

%%
classes= 1:length(env.class_names); %[1 3 7 8 9] %1:max(lb_plot); %1 2 9] ; % classes to plot % 
ft_plot_db=pow2db(ft_plot);
for i=classes % iterate over classes %%
    class{i} = ft_plot_db(lb_plot==i, 1:skip_idx:max_idx); % only raw images, rescale and take linear
    try
        h=scatter3(class{i}(:,1), class{i}(:,2), class{i}(:,3), 'o',...
            'SizeData', PLOT_size_data, 'MarkerFaceAlpha', a, 'MarkerEdgeAlpha', a,...
            'MarkerFaceColor', env.plot.colors{i}, 'MarkerEdgeColor', env.plot.colors{i});
    catch % if no colors defined
            h=scatter3(class{i}(:,1), class{i}(:,2), class{i}(:,3), 'o',...
            'SizeData', PLOT_size_data, 'MarkerFaceAlpha', a, 'MarkerEdgeAlpha', a,...
            'MarkerFaceColor', 'flat');
    end
%     h=plot3(class{i}(:,1), class{i}(:,2), class{i}(:,3), '.',...
%         'MarkerSize', 30);
    set(gca, 'XScale', 'linear', 'YScale', 'linear','ZScale', 'linear');
end
hold off
box on
xlabel('Double bounce (dB)')
ylabel('Volume scatter (dB)')
zlabel('Single bounce (dB)')
% h.LineWidth=10
% h.MarkerFaceColor='filled'
if 1==0
    legend(env.class_names_full(classes))
else    legend(env.class_names(classes), 'Location', 'eastoutside') % if diff number classes
    disp('Using class name abrevs')
end
title('Training classes used')
axis([-50 10 -50 20]);
view(0,90)

%% 2D gscatter plot (no alpha)

if 1==2
    figure;
    gscatter(ft_plot_db(:,1+featOS+0*skip_idx), ft_plot_db(:,1+featOS+1*skip_idx), lb_plot)
    legend(env.class_names, 'Location', 'best')
    title('Training classes used')
    % set(gca, 'XScale', 'log', 'YScale', 'log');
end  

%% vis grid with class boundaries
grid=logspace(-3,1,40);
% ft_grid=repmat(mean(ft_all), numel(grid)^3, 1); % uniform values for other features
ft_grid=random('Exponential', 0.12, numel(grid)^3,size(ft_all,2)); % random values for other features
[x,y,z]= ndgrid(grid, grid,grid);
ft_grid(:,1+0*skip_idx)=x(:);
ft_grid(:,1+1*skip_idx)=y(:);
ft_grid(:,1+2*skip_idx)=z(:);


%% Predict grid
ft_grid=ft_all(holdout.test,:); % uncomment to use holdout in testing
% ft_grid=ft_all; % uncomment for testing to replicate training data
% ft_grid=ft_grid+random('Exponential', 0.06, size(ft_grid)); % uncomment to add random perturbation
[~,scores_valid] = predict(model.treeBag,ft_grid);
[~,indOfMax_valid] = max(scores_valid,[],2);
ft_grid_db=pow2db(ft_grid);

%% Plot grid classes with gscatter
if 1==2
    figure;
    gscatter(ft_grid_db(:,1+featOS+0*skip_idx), ft_grid_db(:,1+featOS+1*skip_idx),indOfMax_valid)
    legend(env.class_names, 'Location', 'best')
    title('Classification result from test data')
end

%% Plot grid classes with scatter3
figure; hold on
classes= 1:length(env.class_names); %[1 3 7 8 9] %1:max(lb_plot); %1 2 9] ; % classes to plot % 
for i=classes % iterate over classes %%
    class_grid{i} = ft_grid_db(indOfMax_valid==i, 1+featOS:skip_idx:max_idx); % only raw images, rescale and take linear
    h=scatter3(class_grid{i}(:,1), class_grid{i}(:,2), class_grid{i}(:,3), 'o',...
    'SizeData', PLOT_size_data, 'MarkerFaceAlpha', a, 'MarkerEdgeAlpha', a,...
    'MarkerFaceColor', 'flat');
end
hold off
box on
xlabel('Double bounce (dB)')
ylabel('Volume scatter (dB)')
zlabel('Single bounce (dB)')
% h.LineWidth=10
% h.MarkerFaceColor='filled'
legend(env.class_names(classes)) % if diff number classes
title('Classification result from test data')
axis([-50 10 -50 20 -40 10 ]);
view(0,90)

%% save animated video - uncomment
% figure(1)
% nFrames=200;
% viewZ=30*ones(nFrames,2);
% viewZ(:,1)=linspace(0,360, nFrames);
% vid_file=['D:\vid\AGU2019GIFs\centroidPlot',date,'.gif'];
% CaptureFigVid_EK(viewZ, vid_file,20)