% takes 3-band scattering file with probabilities and assigns class based
% on greatest prob

% TODO: moving window? rescaling? Fix moving window speed!!
%% begin
clear; close all

%% I/O
dir_in='F:\UAVSAR\padelW_18034_17076_006_170808_PL09043020_CX_01\C3\';
rescale=0;
movW=2;
%% Other params
file_in_s='Freeman_Odd';
file_in_d='Freeman_Dbl';
file_in_v='Freeman_Vol';
mask='mask_valid_pixels';
file_in={file_in_s, file_in_d, file_in_v};

%% load data
for i=1:3
    datafile{i}=[dir_in, file_in{i}, '.bin'];
    hdrfile{i}=[dir_in, file_in{i}, '.bin.hdr'];
    [D(:,:,i),info{i}]=enviread(datafile{i},hdrfile{i});
end

%% load mask
msk_in=[dir_in, mask, '.bin'];
hdrfile=[dir_in, mask, '.bin.hdr'];
[BW, BW_header]=enviread(msk_in,hdrfile);

%% ID nodata values
BW=logical(repmat(BW, [1 1 3]));
D(~BW)=NaN;

%% rescale
if rescale
    movW_sum=movW*2+1;
    rescale_txt=sprintf('_%dx%d',movW_sum, movW_sum);
    for i=1:3
        D(:,:,i)=imadjust(D(:,:,i));
    end
else
    rescale_txt='';
end

%% Moving window / MLE
if movW~=0
    movW_text='_mv';
    fun=@(D) max_fun(D);
    sc=blockproc(D, [1,1], fun, 'BorderSize', [movW movW], 'TrimBorder', false, 'PadPartialBlocks', true, 'useparallel', 1);
else
    movW_text='';  
    [~, sc]=max(D, [],3);
end
% %% MLE
% [~, sc]=max(D, [],3);

%% write file
SC(~BW(:,:,1))=0; % NoData for output
file_out=[dir_in, 'Freeman_MLE', rescale_txt, movW_text, '.tif'];
R=info2r(BW_header);
geotiffwrite(file_out, uint8(sc), R)