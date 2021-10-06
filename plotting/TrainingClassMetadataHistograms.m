% for making plot for ORNL DAAC
load('F:\PAD2019\classification_training\PixelClassifier\Test40\model.mat')
load('F:\PAD2019\classification_training\PixelClassifier\Test40\training.mat')

U=[lb_all, info_all];
C = unique(U,'rows');

h=histogram(C(:,1), 'binmethod', 'integers');
h.Values'
set(gca, 'XTick', [1:13])
set(gca, 'XTickLabel', model.env.class_names)
xlabel('Class')
ylabel('Feature count')
set(gca, 'FontName', 'ariel', 'FontSize', 34, 'LineWidth', 1.5)
% manually edit plot
Env_PixelClassifier
savefigs('ORNL-class-plot-v2')

figure
h2=histogram(U(:,1), 'binmethod', 'integers');
h2.Values'
