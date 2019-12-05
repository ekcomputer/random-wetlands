% script to visualize image features (filtered images)
% run after pixelClassifierTrain (need F data structure)
figure
lfn=length(featNames);
% a=[540.93       2056.1       786.04       1871.5]; % viewing window
% a=[498.34       728.82       201.06       400.78]; % viewing window
a=[499.61       592.83       222.75       320.78];
colormap gray
rs=1; % resize amount
ratio=rs/0.2; % correction for window/resize
featNames1=featNames; % use default
featNames1={'Image', 'Gaussian $\sigma$=2', 'Gaussian $\sigma$=2 $dx$',...
    'Gaussian $\sigma$=2 $dy$', 'Gaussian $\sigma$=2 $dxdx$',...
    'Gaussian $\sigma$=2 $dxdy$', 'Gaussian $\sigma$=2 $dydy$',...
    'Hess $\sigma$=2 EV=1', 'Hess $\sigma$=2 EV=2', 'Gaussian $\sigma$=2 Edge',...
    'Lagr. of Gaussian $\sigma$=2', 'Steer. Filter \newline $\sigma$=4 $dydy$',...
    'Steerable Filter $\sigma$=8 $dydy$', 'Std. Dev. 3x3', 'Std. Dev. 7x7'};
for k=1:lfn % parfor
    disp(featNames{k})
    subplot(4,4,k)
%     imagesc(imresize(imadjust(rescale(F(:,:,k))), rs)); axis(ratio*a)
    title(featNames1{k}, 'FontSize', 14)
%     set(gca, 'XTickLabel', [], 'YTickLabel', [])
%     drawnow
end

set(gcf, 'Position',[-1554.5 -555.5 1129.5 1056.5])