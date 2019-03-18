% for georeferencing PolsAR output BMP files
% modified form importGRD.m

n=1;
nextSection=false;
%     dir_in='D:\UAVSAR\redber_30704_17092_000_170907_L090_CX_01\Pout\T3\';
% dir_in='D:\UAVSAR\padelW_18034_17076_006_170808_PL09043020_CX_01\C3\';
dir_in='D:\UAVSAR\PADELT_36000_17062_003_170613_L090_CX_01\C3\';
while  ~nextSection

%     dir_out='D:\UAVSAR\redber_30704_17092_000_170907_L090_CX_01\Georeferenced\';
    dir_out=[dir_in, 'Georeferenced\'];
    files=cellstr(ls([dir_in, '*.bmp']));
    lfiles=length(files); 
    disp('files found:')
    disp(files)
    file_in=[dir_in, files{n}];
    fprintf('Processing file:\n\t%s\n', file_in)
    proceed=input('Proceed? y/n: ', 's');
    if proceed=='n'
        n=double(input('Enter new file number: '));
    elseif proceed=='y'
        nextSection=true;
    else disp('??')
    end
end
disp('Importing file...')

%% mkdir

if~exist(dir_out)
    mkdir(dir_out);
end
%% multiband import
% order of values: Redberr, padelW, PADELT

% r.y=15908; %raster info: pixels
% r.x=15834;
% r.y=281927 ;
% r.x=9900;
% r.y=31265;
% r.x=3570;
r.y=31243 ;
r.x=3580;

% r.py=5.556e-05; %pixel size % GRD Latitude Pixel Spacing
% r.px=.00011111;
% r.py=5.556e-05  ;
% r.px=0.00011111 ;
r.py=5.556e-05 ;
r.px=0.00011111 ;


% r.lat=52.87550748; %NW corner coords %Center Latitude of Upper Left Pixel of GRD Image 
% r.long=-107.63881248999999;
% r.lat=59.32680132 ;
% r.long= -111.56910652    ;
r.lat=59.43464328      ;
r.long=-111.60743947   ;

disp('adding spatial reference...')
%% Define spatial ref
R=georefcells();

%% modify

R.RasterSize=[r.y r.x];
% R.XIntrinsicLimits=[.5 r.x+.5];
% R.YIntrinsicLimits=[.5 r.y+.5];
R.LatitudeLimits=[r.lat-r.py*r.y, r.lat];
R.LongitudeLimits=[r.long  r.long+r.px*r.x];
R.CellExtentInLatitude=r.py;
R.CellExtentInLongitude=r.px;
R.ColumnsStartFrom= 'north';


%% Write georeferenced file
% location=[dir_out, '\', files{n}, '_G.tif'];
% fprintf('writing file: %s\n', location)
% geotiffwrite(location, ground, R);
% figure; 
% imagesc(ground); 
% axis image; 
% colormap copper
% title(files{n}, 'FontSize', 10)
% disp('Done!')

%% Write world file
worldfilename = getworldfilename(file_in);
worldfilewrite(R, worldfilename)