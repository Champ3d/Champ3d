function f_makebin(varargin)
% F_MAKEBIN creates a cloned project with ony converted protected code (.p)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'password','source_code_dir','binary_code_dir','binary_folder'};

% --- default input value
password        = '';
source_code_dir = '';
binary_code_dir = '';
binary_folder   = '';

% --- check and update input
for i = 1:(nargin-0)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

if strcmpi(password,'champ3d goes to bin')
    
    if isempty(source_code_dir)
        source_code_dir = fileparts(fileparts(which('f_makebin')));
    end
    
    dir_list = dir(source_code_dir);
    folname = cellstr(char(dir_list.name));

    folders = {};
    k = 0;
    for i = 1:length(dir_list)
        fn = folname{i};
        if ~strcmpi(fn,'.') && ~strcmpi(fn,'..') && ~strcmpi(fn,'makebin')
            k = k + 1;
            folders{k} = fn;
        end
    end

    %%
    if isempty(binary_folder)
        binary_folder = 'champ3d_bin';
    end

    if isempty(binary_code_dir)
        binary_code_dir = [fileparts(source_code_dir) filesep binary_folder];
    end
    %%
    for i = 1:length(folders)
        fn_source = [source_code_dir filesep folders{i}];
        fn_bin    = [binary_code_dir filesep folders{i}];
        cd(fn_source);
        pcode(fn_source);
        copyfile([fn_source filesep '*.p'], fn_bin);
        delete([fn_source filesep '*.p']);
    end

end

