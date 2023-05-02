%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.


%--------------------------------------------------------------------------
% --- valid argument list (to be updated each time modifying function)
arglist = {''};

% --- default input value
id_mesh2d = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~strcmpi(build_from,'geo1d')
    error([mfilename ' : #build_from must be specified !']);
end
if isempty(id_mesh2d)
    error([mfilename ' : #id_mesh2d must be given !']);
end
%--------------------------------------------------------------------------
keeparg = {'flog','id_x','id_y'};
argtopass = {};
for i = 1:length(keeparg)
    argtopass{2*i-1} = keeparg{i};
    argtopass{2*i}   = eval(keeparg{i});
end
%--------------------------------------------------------------------------
while iscell(id_mesh2d)
    id_mesh2d = id_mesh2d{1};
end
%--------------------------------------------------------------------------
codeidx * codeidy
codeidx * codeidy * codeidl
%--------------------------------------------------------------------------
tic
fprintf(['Add dom2d #' id_dom2d ' defined by : \n']);
fprintf(['id_x #' strjoin(id_x,', #') '\n']);
fprintf(['id_y #' strjoin(id_y,', #')]);
fprintf(' --- in %.2f s \n',toc);
%--------------------------------------------------------------------------
%----------------------------------------------------------
id_xij = id_x{i}{j};
id_xij = replace(id_xij,'...','');
% checking validity
idxvalid = regexp(all_id_x,[id_xij '\w*']);
% ---
for m = 1:length(idxvalid)
    if sum(idxvalid{m}) >= 1
        codeidx = f_str2code(all_id_x{m});
    end
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------