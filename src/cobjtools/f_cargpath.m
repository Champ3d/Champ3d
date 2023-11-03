function cargpath = f_cargpath(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'arg_name','phydomobj'};

% --- default input value
arg_name = [];
phydomobj = [];

% --- valid depend_on
valid_depend_on = {'celem','cface',...
    'bv','jv','hv','pv','av','phiv','tv','omev','tempv',...
    'bs','js','hs','ps','as','phis','ts','omes','temps'};

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(arg_name)
    error([mfilename ': #arg_name must be given !']);
end
%--------------------------------------------------------------------------
if isfield(phydomobj,'id_emdesign3d')
    id_emdesign3d = phydomobj.id_emdesign3d;
    id_mesh3d = c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d;
elseif isfield(phydomobj,'id_thdesign3d')
    id_thdesign3d = phydomobj.id_thdesign3d;
    id_mesh3d = c3dobj.thdesign3d.(id_thdesign3d).id_mesh3d;
end
%--------------------------------------------------------------------------
if contains(arg_name,'.')
    cargpath = arg_name;
    return
else
    if any(strcmpi(arg_name,{'celem','cface'}))
        cargpath = ['c3dobj.mesh3d.' id_mesh3d '.' arg_name];
    elseif any(strcmpi(arg_name,{'bv','jv','hv','pv','av','phiv','tv','omev', ...
                                 'bs','js','hs','ps','as','phis','ts','omes'}))
        cargpath = ['c3dobj.emdesign3d.' id_emdesign3d '.fields.' arg_name];
    elseif any(strcmpi(arg_name,{'tempv','temps'}))
        cargpath = ['c3dobj.thdesign3d.' id_thdesign3d '.fields.' arg_name];
    else
        cargpath = arg_name;
    end
end



