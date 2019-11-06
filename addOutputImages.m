% script to add n 1-band mask files to make 1 n-band categorical raster
% TODO: generalize so I can use it in other dirs
% Written  by Ethan Kyzivat
function addOutputImages(filename)
global env

%% test params
% filename='*Class*.png'
%% input file type
base_names=ls([env.output.test_dir, filename, '*.png']);

%%
georef_in=(ls([env.output.test_dir, filename, '.tif']));
output_pth=[env.output.test_dir, georef_in(1,1:end-4), '_cls.tif'];
gt=geotiffinfo([env.output.test_dir, georef_in]);
for n=1:size(base_names,1)
    I=imread([env.output.test_dir, base_names(n,:)]);
    if n==1
        out=zeros(size(I), 'uint8');
    end
    out=n*uint8(I)+out;
end

%% write
geotiffwrite(output_pth, out, gt.SpatialRef, 'GeoKeyDirectoryTag',gt.GeoTIFFTags.GeoKeyDirectoryTag);
% gdal_calc.py -A input1.tif -B input2.tif --outfile=result.tif --calc="A+B"