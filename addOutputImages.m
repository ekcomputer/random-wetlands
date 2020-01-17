% script to add n 1-band mask files to make 1 n-band categorical raster
% TODO: generalize so I can use it in other dirs
% Written  by Ethan Kyzivat
function addOutputImages(filename)
global env

%% test params
% filename='*Class*.png'
%% input file type
if ~isunix
    base_names=ls([env.output.test_dir, filename, '*.png']);
else
    f.base_names_0=ls([env.output.test_dir, filename, '*.png']);    %hot fix
    f.base_names_1=textscan(f.base_names_0, '%s', 'Delimiter', '\n');
    base_names=char(f.base_names_1{:});
%     base_names=strjoin(cellstr(f.base_names_2), ' ');
end

%%
georef_in=(ls([env.output.test_dir, filename, '.tif']));
if ~isunix
    output_pth=[env.output.test_dir, georef_in(1,1:end-4), '_cls.tif'];
    gt=geotiffinfo([env.output.test_dir, georef_in]);
else
    output_pth=[georef_in(1,1:end-5), '_cls.tif'];
    gt=geotiffinfo(georef_in(1,1:end-1));   % hot fix
end
for n=1:size(base_names,1)
    if ~isunix     %hot fix
        I=imread([env.output.test_dir, base_names(n,:)]);
    else
        I=imread(base_names(n,:));
    end
    if n==1
        out=zeros(size(I), 'uint8');
    end
    out=n*uint8(I)+out;
end

%% apply mask

test_im=imread([env.output.test_dir, georef_in]);
mask=isnan(test_im(:,:,end)); % negative data mask
out(mask)=env.constants.noDataValue_ouput;
%% write
geotiffwrite(output_pth, out, gt.SpatialRef, 'GeoKeyDirectoryTag',gt.GeoTIFFTags.GeoKeyDirectoryTag);
% gdal_calc.py -A input1.tif -B input2.tif --outfile=result.tif --calc="A+B"

%% Add NoData values to rasters

cmd=sprintf('gdal_edit.py -a_nodata %d %d', env.constants.noDataValue_ouput, output_pth);
system(cmd)