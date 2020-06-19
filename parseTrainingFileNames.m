function names_parsed=parseTrainingFileNames(names)

% removes 'Freeman-inc' or similar from namestring
% Inputs:     names           =   cell array of file names
% 
% Outputs:    names_parsed    =   cell array of parsed names
% 
% Ethan Kyzivat March 2020

for i=1:length(names)
    f(i).parsed=textscan(names{i}, '%s', 'Delimiter', '_');
    names_parsed{i}=strjoin({f(i).parsed{1}{1:8}}, '_');
end
