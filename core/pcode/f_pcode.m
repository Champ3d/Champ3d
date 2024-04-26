function f_pcode(varargin)
% F_MAKEBIN creates a cloned project with ony converted protected code (.p)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'password','source_code_dir','p_code_dir','p_folder'};

% --- default input value
password        = '';
source_code_dir = '';
p_code_dir = '';
p_folder   = '';

% --- check and update input
for i = 1:(nargin-0)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
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
    if isempty(p_folder)
        p_folder = 'champ3d_bin';
    end

    if isempty(p_code_dir)
        p_code_dir = [fileparts(source_code_dir) filesep p_folder];
    end
    %%
    for i = 1:length(folders)
        fn_source = [source_code_dir filesep folders{i}];
        fn_bin    = [p_code_dir filesep folders{i}];
        cd(fn_source);
        pcode(fn_source);
        copyfile([fn_source filesep '*.p'], fn_bin);
        delete([fn_source filesep '*.p']);
    end

end

