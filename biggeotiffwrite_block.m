function biggeotiffwrite_block(FILENAME, A, R, varargin)
% Doesn't work. Use biggeotiffwrite.m instead.
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
% Create an output TIFF file with tile size of 128x128
% varargin = use to set geotiff to false, by setting to 'nogeo'

tileSize      = [384, 384]; % [128, 128]; % has to be a multiple of 16.
outFileWriter = BP_bigTiffWriterEK(FILENAME, R.RasterSize(1), R.RasterSize(2), tileSize(1), tileSize(2));
% Now call blockproc to rearrange the color channels.

g = @(A) A % A.block;
blockproc(FILENAME, tileSize, g, 'Destination', outFileWriter);
outFileWriter.close();

%%
if nargin>3
    if strcmp(varargin(1), 'nogeo')
        return
    else
        % do nothing: continue
    end
else % for backwards compatiability: if only 3 args given
    gti_out=[FILENAME(1:end-4), '.tfw'];
    worldfilewrite(R, gti_out);
end
    
% % function to write a bigtiff
% 
% %create test data
%   test = ones(37899, 38687,3, 'uint8');
% %write it out
%   t = Tiff('test.tiff','w8');
%   setTag(t,'Photometric',Tiff.Photometric.RGB);
%   setTag(t,'PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
%   setTag(t,'BitsPerSample',8);
%   setTag(t,'SamplesPerPixel',3);
%   setTag(t,'ImageLength',size(test ,1));
%   setTag(t,'ImageWidth',size(test ,2));  
%   setTag(t,'Compression',Tiff.Compression.LZW);
%   write(t, test );
%   close(t);
% %read it back
%   t2=Tiff('test.tiff')
%   test2=read(t2);
%   close(t2)
%   