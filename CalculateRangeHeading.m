function heading = CalculateRangeHeading(name, varargin)

% function that looks up heading of aircraft based on flight ID name.  If
% second arg is given, function calls transformHeading.m
% relies on looking up heading from .ann file in a specified directory,
% given by env.asc.annDir

% Input:    name        =   string of flight ID from filename
%           Optional: R =   mapcells ref giving boundin box of image
%           Optional: prj =   mapcells ref projection
% Output:   heading     =   row vector with entries downRange and upRange in radians
%                           downrange is direction that range decreases
%                           positive heading is clockwise
% 
% TESTING
% name='padelE_36000_19059_003_190904_L090_CX_01'
%
% By Ethan Kyzivat March 2020


%% Par 0. Validate inputs

if strcmp(name, 'NaN')
    warning('CalculateRangeHeading has input ''NaN''.  Using default of 0.')
    heading=0;
end
heading=zeros([1 2]);
%% Part I. Parse name
global env
numID=find(strcmp({env.input.name},name)); % entry number in env structure
numID=numID(1); % just in case flight ID appears twice in input structure (as if using different bounding boxes)
if ~isunix % data is local
    rootDir=env.input(numID).im_dir; % root dir
    annDir=[rootDir, filesep, 'raw']; % .ann file dir
    f.pth=dir([annDir, filesep, '*.ann']); % tmp
    annPath=[annDir, filesep, f.pth(1).name];
else % on ASC, data is in repository
    annPath=[env.asc.annDir, filesep, env.input(numID).name, '.ann'];
end

fid=fopen(annPath);
f.raw=textscan(fid, '%s', 'Delimiter', '\n');
f.pegHeadingTruth=strfind(f.raw{1},'set_phdg'); % boolean - ish
f.pegHeadingLine=find(cellfun(@(x)~isempty(x), f.pegHeadingTruth));
f.pegHeadingLineStr=textscan(f.raw{1}{f.pegHeadingLine}, '%s');
pegHeadingDeg=str2double(f.pegHeadingLineStr{1}{4});
% f.pegHeadingLine=strcmp(f.pegHeadingTruth,1)
fclose(fid);

%% Part II. Calculate range headings
% pegHeadingDeg=0.099862744 ; %-145.00670825;
pegHeadingRad=deg2rad(pegHeadingDeg);

heading(1)=mod(pegHeadingRad+pi/2, 2*pi); % downrange: direction that range decreases
heading(2)=mod(pegHeadingRad+3*pi/2, 2*pi); % uprange: direction that range increases

%% Part III. Calculate range headings (optional)

if exist('varargin') >0
   heading=transformHeading(heading, varargin{1}, varargin{2});
else
    warning('No SRS conversion for heading.')
end