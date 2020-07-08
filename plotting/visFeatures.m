% Script to make boxplots of training areas
% To be run after pixelclassifiertrain.m, or after loading run data
% WRitten March 26, 2020
% EDK

%% plot
figure;
for i= 1:length(env.class_names)
    subplot(4,4,i)
    boxplot(ft_all(lb_all==i,:))
%     title(sprintf('Feature %d', i))
    title(env.class_names{i})
    xlabel('feature')
    ylim([0 5])
end
disp(featNames)

%% axis names  (optional)

% barh(featImpRshp), set(gca,'yticklabel',featNames'), set(gca,'YTick',1:length(featNames)), title('feature importance')
% legend_txt=env.plot.bandLabels;

%% plot features and class boundaries
