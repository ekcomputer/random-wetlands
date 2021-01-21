function biggeotiffwrite(FILENAME, A, R, varargin)
% for writing a tiff file that would otherwise be > 4 GB and need to be a
% geotiff and would return a matlab error
%
% Inputs:       FILENAME    Output filename
%               A           Matrix to write
%               R           Spatial ref object (or any object with
%                               RasterSize property)
%               Optional:   If 'nogeo', don't write a .tfw file
%
% Output:       Writes a file, FILENAME
% 
%   FILENAME        = 'example.tif';
% inFileInfo    = imfinfo(inFile);
% outFile       = 'out.tif';
% Create an output TIFF file with tile size of 1024x1024
% varargin = 
%       1.) path to .proj file, if using
%       2.) use to set geotiff to false, by setting to 'nogeo'
%       3.) If 'burn', will also burn proj info into tiff file
% 'w'  will create a classic TIFF file
% 'w8' will create a BigTIFF file
% This option is the only differentiator when writing to these two formats.
% Optional input: if pathname, writes proj file for EPSG 102001
bt     = Tiff(FILENAME,'w8');
% More information on the tags used below is here.

tags.ImageLength         = size(A,1);
tags.ImageWidth          = size(A,2);
tags.Photometric         = Tiff.Photometric.MinIsBlack % Tiff.Photometric.RGB; % this causes a maybe insignificant error
if strcmp(class(A), 'single')
    tags.BitsPerSample       = 32;
else
    error('not a single.')
end
tags.SamplesPerPixel     = size(A,3);
tags.TileWidth           = 128*8;
tags.TileLength          = 128*8;
tags.Compression         = Tiff.Compression.LZW;
tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tags.SampleFormat        = Tiff.SampleFormat.IEEEFP;
tags.Software            = 'MATLAB';
tags.ExtraSamples        = Tiff.ExtraSamples.Unspecified;
tags.RowsPerStrip        = 4.295e6; %128*16; % try setting to 8,000

setTag(bt, tags);
write(bt,  A);
close(bt);
%% If writing out world file
if nargin >= 5 % if two vargins
    if strcmp(varargin{2}, 'nogeo') % if varargin exists in workplace and is file
    else
        gti_out=[FILENAME(1:end-4), '.tfw'];
        worldfilewrite(R, gti_out);
    end
else % if anything is else written, such as 'geo', or if no entry: .tfw will always execute...
    gti_out=[FILENAME(1:end-4), '.tfw'];
    worldfilewrite(R, gti_out);
    fprintf('Creating world file: %s\n', gti_out)
end

%% if writing proj file:
if nargin >= 4 % if first vargin
    if exist(varargin{1})==2 % if varargin exists in workplace and is file
        proj_source=varargin{1};
        [fdir, fname]=fileparts(FILENAME);
        proj_output=[fdir, filesep, fname, '.prj'];
        copyfile(proj_source, proj_output) 
        fprintf('Creating .proj file: %s\n', proj_output)
    end
end

%% if burning proj info into tiff file:
if nargin >= 6 % if third vargin exists
    if strcmp(varargin{3}, 'burn')
        add_tiff_georef(FILENAME) % user function
    end
end