function mat2tiff(mat_file_path, tif_file_path)
    % Function to convert a.MAT file to a.TIF file in preparation for
    % blockproc...
    % set up so that mat_file_path refers to a file with structure F containing
    % image data
    % FYI: Loads entire .mat file matrix into memory
    %
    % Inputs:       mat_file_path    Input .mat file name
    %               tif_file_path    Output .tif file name     
    %               global var 'env'
    %
    % Output:       Writes a file, tif_file_path
    %% begin
    global env
    fprintf('Converting %s >>> %s\n', mat_file_path, tif_file_path)
    disp('Loading .mat file...')
    load(mat_file_path); % returns F ( 3D image)
    if isempty(F)
        error('F is empty... (EK)')
    end
    %% compute georeferencing
%     [~, gt]=georef_out(fname, F, false)
%     biggeotiffwrite(tiff_file_path, F, R, varargin) % biggeotiffwrite

    %% write tiff
        % make fake R
    R.RasterSize(1)=size(F,1);
    R.RasterSize(2)=size(F,2);
    
        % write
    disp('Writing file...')
%     biggeotiffwrite_block(tif_file_path, F, R, 'nogeo')
    biggeotiffwrite(tif_file_path, F, R, env.proj_source, 'nogeo')
    disp('Done.')