% takes 3-band scattering file with probabilities and assigns class based
% on greatest prob

% TODO: moving window? rescaling? Fix moving window speed!!
%% begin
clear; close all

%% I/O
dir_in='F:\UAVSAR\padelE_36000_18047_000_180821_L090_CX_01\sub1k2k\freeman_2\C3\';
rescale=0;
movW=8;
seperateFiles=1;
%% Other params
if seperateFiles
    file_in_s='Freeman_Odd';
    file_in_d='Freeman_Dbl';
    file_in_v='Freeman_Vol';
    file_in={file_in_s, file_in_d, file_in_v};
else
    file_in='entropy_scatt_mecha_freeman';
end
mask='mask_valid_pixels';
%% load data
if seperateFiles
    for i=1:3
        datafile{i}=[dir_in, file_in{i}, '.bin'];
        hdrfile{i}=[dir_in, file_in{i}, '.bin.hdr'];
        [D(:,:,i),info{i}]=enviread(datafile{i},hdrfile{i});
    end
else
    datafile=[dir_in, file_in, '.bin'];
    hdrfile=[dir_in, file_in, '.bin.hdr'];
    [D,info]=enviread(datafile,hdrfile);
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
    rescale_txt='_rsc';
    for i=1:3
        D(:,:,i)=imadjust(D(:,:,i));
    end
else
    rescale_txt='';
end

%% Moving window / MLE
if movW~=0
    movW_sum=movW*2+1;
    D=movmean(D, movW_sum, 'omitnan');   
    movW_text=sprintf('_%dx%d',movW_sum, movW_sum);
else
    movW_text='';  
end
[~, sc]=max(D, [],3);
% %% MLE
% [~, sc]=max(D, [],3);

%% write file
SC(~BW(:,:,1))=0; % NoData for output
file_out=[dir_in, 'Freeman_MLE', rescale_txt, movW_text, '.tif'];
R=info2r(BW_header);
geotiffwrite(file_out, uint8(sc), R)