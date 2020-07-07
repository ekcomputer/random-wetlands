% script to plot machine-learning style visualization of class centroids
% run after pixelClassifierTrain (need F data structure) for 3 bands

% TODO: meshgrid a la: https://www.mathworks.com/help/stats/examples/classification.html
% TODO: log transform as its own variable
Env_PixelClassifier;


%% I/O
PLOT_size_data=40; %110;

%% reclassify
ft_plot=ft_all;
lb_plot=lb_all;
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
for i=classes % iterate over classes %%
    class{i}=-log10(-min(min(ft_plot))+ ft_plot(lb_plot==i, 1:skip_idx:max_idx)); % only raw images, rescale and take linear
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
xlabel('Double bounce')
ylabel('Volume scatter')
zlabel('Single bounce')
% h.LineWidth=10
% h.MarkerFaceColor='filled'
if 1==0
    legend(env.class_names_full(classes))
else    legend(env.class_names(classes)) % if diff number classes
    disp('Using class name abrevs')
end


%% 2D gscatter plot

figure;
gscatter(ft_plot(:,1+1*skip_idx), ft_plot(:,1+2*skip_idx), lb_plot)
legend(env.class_names, 'Location', 'best')
set(gca, 'XScale', 'log', 'YScale', 'log');
    
%% save animated video - uncomment
% nFrames=250;
% viewZ=30*ones(nFrames,2);
% viewZ(:,1)=linspace(0,360, nFrames);
% vid_file='D:\vid\AGU2019GIFs\centroidPlot_revised1.gif';
% CaptureFigVid_EK(viewZ, vid_file,20)