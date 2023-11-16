function c3dobj = f_add_emdesign2d(c3dobj,varargin)
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
arglist = {'id_mesh2d','id_emdesign',...
           'em_model','frequency', 'from'};

% --- default input value
id_mesh2d = [];
id_emdesign = [];
em_model = 'fem_aphijw'; % fem_aphijw, fem_aphits, fem_tomejw, fem_tomets;
frequency = 0;
from = [];

% --- valid em_model
valid_em_model = {'2d_fem_aphijw', '2d_fem_aphits', '2d_fem_tomejw', '2d_fem_tomets', ...
                  '2d_fem_bem_aphijw', '2d_fem_bem_aphits', '2d_fem_bem_tomejw', '2d_fem_bem_tomets'};

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh2d)
    id_mesh2d = fieldnames(c3dobj.mesh2d);
    id_mesh2d = id_mesh2d{1};
end
%--------------------------------------------------------------------------
if iscell(id_mesh2d)
    if length(id_mesh2d) > 1
        error([mfilename ' : only one mesh2d allowed !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_emdesign)
    id_emdesign = 'emdesign2d_01';
end
%--------------------------------------------------------------------------
if ~any(strcmpi(em_model,valid_em_model))
    error([mfilename ': #em_model ' em_model ' is not valid. Chose : ' strjoin(valid_em_model,', ') ' !']);
end
%--------------------------------------------------------------------------
if any(strcmpi(em_model,{'2d_fem_bem_aphijw', '2d_fem_bem_aphits', '2d_fem_bem_tomejw', '2d_fem_bem_tomets'}))
    if isempty(from)
        error([mfilename ': #from must be given !']);
    end
end
%--------------------------------------------------------------------------
if ~isempty(from)
    from__ = f_to_scellargin(from);
    id_emdesign__ = fieldnames(c3dobj.emdesign);
    for i = 1:length(from__)
        if ~any(strcmpi(from__{i},id_emdesign__))
            error([mfilename ': from #' from__{i} ' is not valid. Chose : ' strjoin(id_emdesign__,', ') ' !']);
        end
    end
end
%--------------------------------------------------------------------------
switch em_model
    case {'2d_fem_aphijw'}
        formulation = 'aphi';
        model_type = 'frequency_domain';
        discretization = 'fem';
    case {'2d_fem_aphits'}
        formulation = 'aphi';
        model_type = 'time_domain';
        discretization = 'fem';
    case {'2d_fem_tomejw'}
        formulation = 'tome';
        model_type = 'frequency_domain';
        discretization = 'fem';
    case {'2d_fem_tomets'}
        formulation = 'tome';
        model_type = 'time_domain';
        discretization = 'fem';
    case {'2d_fem_bem_aphijw'}
        formulation = 'aphi';
        model_type = 'frequency_domain';
        discretization = 'fem_bem';
    case {'2d_fem_bem_aphits'}
        formulation = 'aphi';
        model_type = 'time_domain';
        discretization = 'fem_bem';
    case {'2d_fem_bem_tomejw'}
        formulation = 'tome';
        model_type = 'frequency_domain';
        discretization = 'fem_bem';
    case {'2d_fem_bem_tomets'}
        formulation = 'tome';
        model_type = 'time_domain';
        discretization = 'fem_bem';
end
%--------------------------------------------------------------------------
c3dobj.emdesign.(id_emdesign).id_mesh2d      = id_mesh2d;
c3dobj.emdesign.(id_emdesign).em_model       = em_model;
c3dobj.emdesign.(id_emdesign).dimension      = 2;
c3dobj.emdesign.(id_emdesign).formulation    = formulation;
c3dobj.emdesign.(id_emdesign).model_type     = model_type;
c3dobj.emdesign.(id_emdesign).discretization = discretization;
c3dobj.emdesign.(id_emdesign).frequency      = frequency;
c3dobj.emdesign.(id_emdesign).from           = from;
% ---
c3dobj.emdesign.(id_emdesign).fields.bv    = [];
c3dobj.emdesign.(id_emdesign).fields.jv    = [];
c3dobj.emdesign.(id_emdesign).fields.hv    = [];
c3dobj.emdesign.(id_emdesign).fields.pv    = [];
c3dobj.emdesign.(id_emdesign).fields.av    = [];
c3dobj.emdesign.(id_emdesign).fields.phiv  = [];
c3dobj.emdesign.(id_emdesign).fields.tv    = [];
c3dobj.emdesign.(id_emdesign).fields.omev  = [];
% ---
c3dobj.emdesign.(id_emdesign).fields.bs    = [];
c3dobj.emdesign.(id_emdesign).fields.js    = [];
c3dobj.emdesign.(id_emdesign).fields.hs    = [];
c3dobj.emdesign.(id_emdesign).fields.ps    = [];
c3dobj.emdesign.(id_emdesign).fields.as    = [];
c3dobj.emdesign.(id_emdesign).fields.phis  = [];
c3dobj.emdesign.(id_emdesign).fields.ts    = [];
c3dobj.emdesign.(id_emdesign).fields.omes  = [];
%--------------------------------------------------------------------------
% --- Log message
if iscell(id_mesh2d)
    f_fprintf(0,'Add #emdesign',1,id_emdesign,0,'with #mesh2d',1,id_mesh2d,0,'\n');
elseif ischar(id_mesh2d)
    f_fprintf(0,'Add #emdesign',1,id_emdesign,0,'with #mesh2d',1,id_mesh2d,0,'\n');
else
    f_fprintf(0,'Add #emdesign',1,id_emdesign,0,'\n');
end




