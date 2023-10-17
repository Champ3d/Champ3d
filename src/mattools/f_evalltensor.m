function ltensor_array = f_evalltensor(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'phydomobj','ltensor'};

% --- default input value
phydomobj = [];
ltensor = [];

% --- default output value
ltensor_array = [];

% --- valid depend_on
valid_ltensor = {'main_value','ort1_value','ort2_value',...
                 'main_dir','ort1_dir','ort2_dir'};

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
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
id_dom3d  = phydomobj.id_dom3d;
id_elem   = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
nb_elem   = length(id_elem);
%--------------------------------------------------------------------------
ltfield__ = fieldnames(ltensor);
%--------------------------------------------------------------------------
for iltf = 1:length(ltfield__)
    %----------------------------------------------------------------------
    ltfield = ltensor.(ltfield__{iltf});
    paramtype = f_paramtype(ltfield);
    %----------------------------------------------------------------------
    if any(strcmpi(paramtype,{'c3d_parameter_function'}))
        param = f_evalisofun(c3dobj,'phydomobj',phydomobj,'iso_function',ltfield);
        %------------------------------------------------------------------
        % --- Output
        ltensor_array.(ltfield__{iltf}) = param;
        %------------------------------------------------------------------
    elseif any(strcmpi(paramtype,{'numeric'}))
        ltensor_array.(ltfield__{iltf}) = repmat(ltfield,nb_elem,1);
    else
        f_display(ltfield);
        error([mfilename ' : cannot evaluate ltensor field !']);
    end
end
%--------------------------------------------------------------------------
if isempty(ltensor_array)
    f_display(ltensor);
    error([mfilename ' : cannot evaluate ltensor !']);
end

