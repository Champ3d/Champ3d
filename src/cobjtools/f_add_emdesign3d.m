function c3dobj = f_add_emdesign3d(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','id_emdesign3d',...
           'em_model','frequency'};

% --- default input value
id_mesh3d = [];
id_emdesign3d = [];
em_model = 'aphijw'; % aphijw, aphits, tomejw, tomets;
frequency = 0;

% --- valid em_model
valid_em_model = {'aphijw', 'aphits', 'tomejw', 'tomets'};

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    id_mesh3d = fieldnames(c3dobj.mesh3d);
    id_mesh3d = id_mesh3d{1};
end

if isempty(id_emdesign3d)
    id_emdesign3d = 'emdesign3d_01';
    %error([mfilename ' : #id_emdesign3d must be given !']);
end

%--------------------------------------------------------------------------
if ~any(strcmpi(em_model,valid_em_model))
    error([mfilename ': #em_model ' em_model ' is not valid. Chose : ' strjoin(valid_em_model,', ') ' !']);
end
%--------------------------------------------------------------------------
switch em_model
    case {'aphijw'}
        formulation = 'aphi';
        model_type = 'frequency_domain';
    case {'aphits'}
        formulation = 'aphi';
        model_type = 'time_domain';
    case {'tomejw'}
        formulation = 'tome';
        model_type = 'frequency_domain';
    case {'tomets'}
        formulation = 'tome';
        model_type = 'time_domain';
end
%--------------------------------------------------------------------------
c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d   = id_mesh3d;
c3dobj.emdesign3d.(id_emdesign3d).em_model    = em_model;
c3dobj.emdesign3d.(id_emdesign3d).formulation = formulation;
c3dobj.emdesign3d.(id_emdesign3d).model_type  = model_type;
c3dobj.emdesign3d.(id_emdesign3d).frequency   = frequency;

% --- Log message
if iscell(id_mesh3d)
    fprintf(['Add emdesign3d #' id_emdesign3d ' with mesh3d #' strjoin(id_mesh3d,', #') '\n']);
elseif ischar(id_mesh3d)
    fprintf(['Add emdesign3d #' id_emdesign3d ' with mesh3d #' id_mesh3d '\n']);
else
    fprintf(['Add emdesign3d #' id_emdesign3d '\n']);
end




