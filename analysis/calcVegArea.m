%  Script to calculate total vegetated area for each water body
% Inputs:           input dir containing list of classified rasters
%                   water_classes =         class numbers for water or
%                                           inundated vegetation
%                   Buffer distance
%
% Outputs:          Writes xlsx table, if uncommented
%
% NOTE: 'lake' is used synonmously w 'water body'
%  Ethan Kyzivat, April 2020


% TODO: Add buffers to filter out disconnected littoral zones w no water nearby,
% why is median_lake_frac_inun_veg always 100%  Why so
% many veg-only lakes?  Add defensive checks if I change or add classes.
% Output .mat file. Filter by size, or buffered water bodies with only
% littoral...

%% params
clear

Env_PixelClassifier
wet_classes=[2,3,4,5];
water_classes=[2];
PLOT_xtick_rot=0; % 45 % PLOT xticklabel rotation
PLOT_view_rot=[90 -90];
regionPropsStats = 0; % save time by not calc regionprops
TF_msk_littoral_only = 1; % mask out littoral only 'lakes'

%% I/O
dir_in='D:\GoogleDrive\ABoVE top level folder\Kyzivat_ORNL_DAAC_2021\lake-wetland-maps\5-classes'; % 26 was used for first plots
% dir_in='F:\PAD2019\classification_training\PixelClassifier\Test31';
files_in=dir([dir_in, filesep, '*cls.tif']); % list of classified tifs
nFiles=length(files_in);
for i=1:nFiles %3 % Loop over files
    
    %% Load image
    pth=[dir_in, filesep, files_in(i).name];
    fprintf('Loading image %d: \n\t%s \n', i, files_in(i).name)
    im=uint8(geotiffread(pth));
    gti=geotiffinfo(pth);
    px_size=gti.SpatialRef.CellExtentInWorldX*gti.SpatialRef.CellExtentInWorldY; % m2 for Albers
    
    %% validate data
    if range(im(:))==0
        warning('Image value is invariant. Something is wrong. Skipping...')
        continue
    else
        %% create masks 
        msk_wet=ismember(im, wet_classes);
        nPx=sum(im(:)>0);
        %% regionprops
        if regionPropsStats % if using region props stats
            rpstats(i).props=regionprops(msk_wet, im, 'PixelValues', 'Area', 'Perimeter', 'Centroid');
        end
        %% Loop over regions and littoral only 'lakes'
            % note: area is in px for now
        if regionPropsStats % if using region props stats
            stats(i).PROP_num_water_bodies=length(rpstats(i).props);
            msk_littoral_only=false(1,stats(i).PROP_num_water_bodies); % init % positive mask
            for j=1:stats(i).PROP_num_water_bodies
               rpstats(i).props(j).px_water=sum(ismember(rpstats(i).props(j).PixelValues, water_classes)); 
               rpstats(i).props(j).px_inun_veg=rpstats(i).props(j).Area-rpstats(i).props(j).px_water;
               rpstats(i).props(j).lake_frac_inun_veg=rpstats(i).props(j).px_inun_veg/rpstats(i).props(j).Area;
        %        rpstats(i).props(j).frac_inun_veg=rpstats(i).props(j).px_inun_veg/nPx; 
            end
            if TF_msk_littoral_only
                msk_littoral_only=[rpstats(i).props.lake_frac_inun_veg] < 1;
                rpstats(i).props=rpstats(i).props(msk_littoral_only);
            end
        end

        %% summary stats
        stats(i).px_water=sum(sum(ismember(im, water_classes)));
        stats(i).px_wet=sum(msk_wet(:));
        stats(i).px_inun_veg=stats(i).px_wet-stats(i).px_water;
        stats(i).px_dry=nPx-stats(i).px_wet;
        stats(i).nValidPx=nPx;
        stats(i).nPx=numel(im);
        stats(i).frac_inun_veg=stats(i).px_inun_veg/nPx;
        stats(i).frac_wet=stats(i).px_wet/nPx;
        stats(i).mean_lake_frac_inun_veg=stats(i).px_inun_veg/stats(i).px_wet;
        stats(i).LP_ratio_mean=stats(i).px_inun_veg/stats(i).px_water;
        stats(i).name=files_in(i).name;
        if regionPropsStats
            stats(i).PROP_med_lake_frac_inun=median([rpstats(i).props.lake_frac_inun_veg]); 
            stats(i).PROP_num_profundal_only_lakes=sum([rpstats(i).props.px_inun_veg]==0);    % lakes w only open water
            stats(i).PROP_frac_profundal_only_lakes= stats(i).PROP_num_profundal_only_lakes / ...
                stats(i).PROP_num_water_bodies;
            stats(i).PROP_num_littoral_lakes=sum([rpstats(i).props.px_inun_veg]>0 &...
                [rpstats(i).props.px_water]>0);         % lakes w open and inun veg
            stats(i).PROP_frac_littoral_lakes=stats(i).PROP_num_littoral_lakes / ...
                stats(i).PROP_num_water_bodies;
            stats(i).PROP_num_littoral_only_lakes=sum([rpstats(i).props.px_water]==0);    % lakes w no open water
            stats(i).PROP_frac_littoral_only_lakes=stats(i).PROP_num_littoral_only_lakes / ...
                stats(i).PROP_num_water_bodies;
            % HERE: add mean/med LP ratio, after filtering out littoral
            % only lakes
        end
        
        %% summary stats in loop
        for j = 1:length(env.class_names)
            stats(i).(['px_',env.class_names{j}])=sum(ismember(im(:), j));
        end

%                 %% Convert to shapefile (from rasters2Shp.m)
% %         R=gti. ...
% %         intrinsic=vertcat(rpstats(i).props.Centroid);
% %         [world(:,1), world(:,2)]=intrinsicToWorld(R,intrinsic(:,1), intrinsic(:,2));
%         mstruct=geotiff2mstruct(gti); % get map projection structure to convert to lat/long
%             
%             % to test
%             
%         bound=bwboundaries(msk_wet, 4);   
% %         bound_noHoles=bwboundaries(msk, 'noholes');  
%         
%         convert=@(x) polyshape(x, 'Simplify', false);
%         shp0=cellfun(convert, bound);
%         shp0=simplify(shp0); % gives lots of warnings...
% %         shp1=cellfun(convert, bound_noHoles);
% %         shp1=simplify(shp1);
% %         shp_holes=xor(shp0, shp1); % <------------------here
%         
%         shp=mapshape(); shp.Geometry='polygon';
    %%     Plot 1
        if regionPropsStats
%             subplot(nFiles, 2, 2*i-1)
%             imagesc(imresize(im, 0.2)); axis off
%             title(files_in(i).name, 'FontSize', 10, 'Interpreter', 'latex')

            subplot(ceil(sqrt(nFiles)), ceil(sqrt(nFiles)), i)
%             histogram([rpstats(i).props.lake_frac_inun_veg])
            histogram([rpstats(i).props.lake_frac_inun_veg])
            if i==nFiles % last time only
                xlabel('Fraction inundated veg.')
                ylabel('Count')
            end
            % plot scrap
%             scatter([rpstats(i).props([rpstats(i).props.lake_frac_inun_veg]>0).Area], [rpstats(i).props([rpstats(i).props.lake_frac_inun_veg]>0).lake_frac_inun_veg])
%             set(gca, 'XScale', 'log')
%             xlabel('Area')
%             ylabel('littoral fraction')
%             mean([rpstats(i).props([rpstats(i).props.lake_frac_inun_veg]>0).lake_frac_inun_veg])
%             median([rpstats(i).props([rpstats(i).props.lake_frac_inun_veg]>0).lake_frac_inun_veg])
% 
%             histogram([rpstats(i).props.lake_frac_inun_veg], logspace(-5, 0, 30))
%             set(gca, 'XScale', 'log')
%             xlabel('Littoral fraction')
            ylabel('count')

            drawnow
        end
    end
end

%% mask out error rows
msk_empty=false(1,length(stats)); % positive mask
for i=1:length(stats)
    msk_empty(i)=~isempty(stats(i).nPx);
end
disp('Masking out empty rows.')
stats=stats(msk_empty);
nRows=length(stats);

%% convert to table
stats_tbl=struct2table(stats);

%% Plot 2
% set(groot,'defaultTextInterpreter','none')
% simple_labels={'Baker 2019 Sept', 'PAD 2018 Aug', 'PAD 2019 Sept',...
%     'YF East 2017 Sept', 'YF West 2017 Sept', 'YF West 2017 June'}
% simple_labels=split(num2str(1:nRows));
fun=@(str) str(1:18);
simple_labels=cellfun(fun, {stats.name}, 'UniformOutput', false);
% plot_order=[1 2 3 6 5 4]
% plot_order=1:nRows; %setdiff(1:nFiles, 20);
% plot_order= [1,2,4,3,14,7,6,5,9,8,13,12,11,10];
% plot_order=flip([14,13,11,12,6,7,2,3,4,5,1,8,9,10]); % Run 32
plot_order=1:length(stats); 
% plot_order=flip((length(stats)+1)*ones(1,length(stats))-...
%     [1 2 4 3 17 6 5 16 9 8 7 11 10 15 14 13 12]); % for 17 scenes
figure(2)

bar(stats_tbl.frac_inun_veg(plot_order)*100, 'FaceColor', [0.19,0.47,0.05]) %[0.22,0.60,0.41])
set(gca, 'XTick', 1:length(stats), 'XTickLabel', simple_labels(plot_order), 'XTickLabelRotation', PLOT_xtick_rot,...
    'TickLabelInterpreter', 'none', 'view',PLOT_view_rot)
ylabel('Inundated veg. (% of total area)')

%% Plot 3
figure(3)

mat2=[[stats.px_water]; [stats.px_inun_veg]; [stats.px_dry]]./[stats.nValidPx]*100;
b=bar(mat2(:,plot_order)', 'stacked', 'FaceColor', 'flat'); %set(gca, 'XTick', 1:size(cols.water,1), 'XTickLabel', (lbl_dates))
% colors={'blue', 'green', 'brown'};
% colormap(flip(brewermap(3, 'RdYlBu')));
colormap(env.plot.colors_mat([1 4 5],:));
for k = 1:size(mat2,1)
    b(k).CData = k;
end
set(gca, 'XTickLabel', simple_labels(plot_order), 'XTickLabelRotation', PLOT_xtick_rot,...
    'TickLabelInterpreter', 'none', 'view',PLOT_view_rot, 'XTick', 1:length(stats))
ylabel('Landcover classes (% of total area)')
legend({'Water', 'Inundated \newlinevegetation', 'Dry \newlinevegetation'}, 'Location', 'eastoutside', 'Interpreter','tex')
% title({'Wetland change:', 'Peace-Athabasca Delta'})

%% Plot 4
figure(4)

bar(stats_tbl.mean_lake_frac_inun_veg(plot_order)*100, 'FaceColor', [0.19,0.47,0.05])
set(gca, 'XTickLabel', simple_labels(plot_order), 'XTickLabelRotation', PLOT_xtick_rot,...
    'TickLabelInterpreter', 'none', 'view',PLOT_view_rot, 'XTick', 1:length(stats))
ylabel('Inundated veg. (% of total lake area)')

%% Plot 5
figure(5)

bar(stats_tbl.px_wet(plot_order)./stats_tbl.nValidPx(plot_order)*100, 'FaceColor', [0.15,0.67,0.54])
set(gca, 'XTickLabel', simple_labels(plot_order), 'XTickLabelRotation', PLOT_xtick_rot,...
    'TickLabelInterpreter', 'none', 'view',PLOT_view_rot, 'XTick', 1:length(stats))
ylabel('Wet area (% of total area)')
%% Display:
disp('Result:')
disp('')

%% output table
% fname=sprintf('summaryStats_%s.xlsx', date);
% writetable(struct2table(stats), fname)
% fprintf('Saved: %s\n', fname)
