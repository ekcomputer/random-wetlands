function biggeotiffwrite_block(FILENAME, A, R)
%   FILENAME        = 'example.tif';
% inFileInfo    = imfinfo(inFile);
% outFile       = 'out.tif';
% Create an output TIFF file with tile size of 128x128

tileSize      = [128, 128]; % has to be a multiple of 16.
outFileWriter = BP_bigTiffWriterEK(FILENAME, R.RasterSize(1), R.RasterSize(2), tileSize(1), tileSize(2));
% Now call blockproc to rearrange the color channels.

g = @(A) A
blockproc(FILENAME, tileSize, g, 'Destination', outFileWriter);
outFileWriter.close();

%%
gti_out=[FILENAME(1:end-4), '.tfw'];
worldfilewrite(R, gti_out);
    
    
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