function c3dobj = f_add_thdesign3d(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','id_thdesign3d'};

% --- default input value
id_mesh3d = [];
id_thdesign3d = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    id_mesh3d = fieldnames(c3dobj.geo3d.mesh3d);
    id_mesh3d = id_mesh3d{1};
end

if isempty(id_thdesign3d)
    error([mfilename ' : #id_thdesign3d must be given !']);
end

%--------------------------------------------------------------------------
c3dobj.thdesign3d.(id_thdesign3d).id_mesh3d = id_mesh3d;
% --- Log message
if iscell(id_mesh3d)
    fprintf(['Add thdesign3d #' id_thdesign3d ' with mesh3d #' strjoin(id_mesh3d,', #') '\n']);
elseif ischar(id_mesh3d)
    fprintf(['Add thdesign3d #' id_thdesign3d ' with mesh3d #' id_mesh3d '\n']);
else
    fprintf(['Add thdesign3d #' id_thdesign3d '\n']);
end




