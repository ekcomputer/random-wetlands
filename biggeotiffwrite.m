function biggeotiffwrite(FILENAME, A, R, vargin)
% 'w'  will create a classic TIFF file
% 'w8' will create a BigTIFF file
% This option is the only differentiator when writing to these two formats.
% Optional input: if pathname, writes proj file for EPSG 102001
bt     = Tiff(FILENAME,'w8');
% More information on the tags used below is here.

tags.ImageLength         = size(A,1);
tags.ImageWidth          = size(A,2);
tags.Photometric         = Tiff.Photometric.RGB;
if strcmp(class(A), 'single')
    tags.BitsPerSample       = 32;
else
    error('not a single.')
end
tags.SamplesPerPixel     = size(A,3);
tags.TileWidth           = 128*16;
tags.TileLength          = 128*16;
tags.Compression         = Tiff.Compression.LZW;
tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tags.SampleFormat        = Tiff.SampleFormat.IEEEFP;
tags.Software            = 'MATLAB';
tags.ExtraSamples        = Tiff.ExtraSamples.Unspecified;
tags.RowsPerStrip        = 4.295e6; %128*16;

setTag(bt, tags);
write(bt,  A);
close(bt);

gti_out=[FILENAME(1:end-4), '.tfw'];
worldfilewrite(R, gti_out);

%% if writing proj file:
if exist(varargin{1})==2 % if varargin exists in workplace and is file
    proj_source=varargin{1};
    [fdir, fname]=fileparts(FILENAME);
    proj_output=[fdir, fname, '.proj'];
    copyfile(proj_source, proj_output) 
    fprintf('Creating .proj file: %s\n', proj_output)
end
