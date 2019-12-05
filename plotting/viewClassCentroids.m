% script to plot machine-learning style visualization of class centroids
% run after pixelClassifierTrain (need F data structure) for 3 bands
Env_PixelClassifier;

%% reclassify
ft_plot=ft_all;
lb_plot=lb_all;
    % reclassify - uncomment
% lb_plot(ismember(lb_all, [1 2 3]))=3;
% ft_plot(ismember(lb_all, [1 2 3]))=3;
% lb_plot=lb_plot-2;
% ft_plot=ft_plot-2;

%% plot
a=0.5; % alpha value
% figure; 
clf; hold on
for i=1:max(lb_plot) % iterate over classes
    class{i}=-log10(-min(min(ft_plot))+ ft_plot(lb_plot==i, 1:2:6)); % only raw images, rescale and take linear
    h=scatter3(class{i}(:,1), class{i}(:,2), class{i}(:,3), 'o',...
        'SizeData', 110, 'MarkerFaceAlpha', a, 'MarkerEdgeAlpha', a,...
        'MarkerFaceColor', env.plot.colors{i}, 'MarkerEdgeColor', env.plot.colors{i});
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
legend(env.class_names_full)

%% save animated video - uncomment
% nFrames=250;
% viewZ=30*ones(nFrames,2);
% viewZ(:,1)=linspace(0,360, nFrames);
% vid_file='D:\vid\AGU2019GIFs\centroidPlot.gif';
% CaptureFigVid_EK(viewZ, vid_file,20)