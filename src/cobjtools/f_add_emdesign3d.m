function c3dobj = f_add_emdesign3d(c3dobj,varargin)
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
arglist = {'id_mesh3d','id_emdesign3d',...
           'em_model','frequency', 'from'};

% --- default input value
id_mesh3d = [];
id_emdesign3d = [];
em_model = 'fem_aphijw'; % fem_aphijw, fem_aphits, fem_tomejw, fem_tomets;
frequency = 0;
from = [];

% --- valid em_model
valid_em_model = {'fem_aphijw', 'fem_aphits', 'fem_tomejw', 'fem_tomets', ...
                  'fem_bem_aphijw', 'fem_bem_aphits', 'fem_bem_tomejw', 'fem_bem_tomets'};

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
%--------------------------------------------------------------------------
if iscell(id_mesh3d)
    if length(id_mesh3d) > 1
        error([mfilename ' : only one mesh3d allowed !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_emdesign3d)
    id_emdesign3d = 'emdesign3d_01';
    %error([mfilename ' : #id_emdesign3d must be given !']);
end
%--------------------------------------------------------------------------
if ~any(strcmpi(em_model,valid_em_model))
    error([mfilename ': #em_model ' em_model ' is not valid. Chose : ' strjoin(valid_em_model,', ') ' !']);
end
%--------------------------------------------------------------------------
if any(strcmpi(em_model,{'fem_bem_aphijw', 'fem_bem_aphits', 'fem_bem_tomejw', 'fem_bem_tomets'}))
    if isempty(from)
        error([mfilename ': #from must be given !']);
    end
end
%--------------------------------------------------------------------------
if ~isempty(from)
    from__ = f_to_scellargin(from);
    id_emdesign__ = fieldnames(c3dobj.emdesign3d);
    for i = 1:length(from__)
        if ~any(strcmpi(from__{i},id_emdesign__))
            error([mfilename ': from #' from__{i} ' is not valid. Chose : ' strjoin(id_emdesign__,', ') ' !']);
        end
    end
end
%--------------------------------------------------------------------------
switch em_model
    case {'fem_aphijw'}
        formulation = 'aphi';
        model_type = 'frequency_domain';
        discretization = 'fem';
    case {'fem_aphits'}
        formulation = 'aphi';
        model_type = 'time_domain';
        discretization = 'fem';
    case {'fem_tomejw'}
        formulation = 'tome';
        model_type = 'frequency_domain';
        discretization = 'fem';
    case {'fem_tomets'}
        formulation = 'tome';
        model_type = 'time_domain';
        discretization = 'fem';
end
%--------------------------------------------------------------------------
c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d      = id_mesh3d;
c3dobj.emdesign3d.(id_emdesign3d).em_model       = em_model;
c3dobj.emdesign3d.(id_emdesign3d).formulation    = formulation;
c3dobj.emdesign3d.(id_emdesign3d).model_type     = model_type;
c3dobj.emdesign3d.(id_emdesign3d).discretization = discretization;
c3dobj.emdesign3d.(id_emdesign3d).frequency      = frequency;
c3dobj.emdesign3d.(id_emdesign3d).from           = from;
% ---
c3dobj.emdesign3d.(id_emdesign3d).fields.bv    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.jv    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.hv    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.pv    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.av    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.phiv  = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.tv    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.omev  = [];
% ---
c3dobj.emdesign3d.(id_emdesign3d).fields.bs    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.js    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.hs    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.ps    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.as    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.phis  = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.ts    = [];
c3dobj.emdesign3d.(id_emdesign3d).fields.omes  = [];
%--------------------------------------------------------------------------
% --- Log message
if iscell(id_mesh3d)
    f_fprintf(0,'Add #emdesign3d',1,id_emdesign3d,0,'with #mesh3d',1,id_mesh3d,0,'\n');
elseif ischar(id_mesh3d)
    f_fprintf(0,'Add #emdesign3d',1,id_emdesign3d,0,'with #mesh3d',1,id_mesh3d,0,'\n');
else
    f_fprintf(0,'Add #emdesign3d',1,id_emdesign3d,0,'\n');
end




