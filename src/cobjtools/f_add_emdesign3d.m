function c3dobj = f_add_emdesign3d(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','id_emdesign3d',...
           'formulation','model_type','frequency'};

% --- default input value
id_mesh3d = [];
id_emdesign3d = [];
formulation = 'aphi'; % 'aphi', 'tome'
model_type = 'frequency_domain'; % frequency_domain = fr_domain, time_domain = t_domain
frequency = 0;

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
c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d   = id_mesh3d;
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




