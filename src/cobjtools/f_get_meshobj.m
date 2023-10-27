function meshobj = f_get_meshobj(c3dobj,varargin)
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
arglist = f_arglist('getmeshobj');
varargin = f_validvarargin(varargin,arglist);

% --- default input value
for3d      = 1;
id_mesh2d  = [];
id_dom2d   = [];
id_mesh3d  = [];
id_dom3d   = [];
of_dom3d   = [];
id_emdesign3d  = [];
id_thdesign3d  = [];
id_econductor  = [];
id_mconductor = [];
id_coil = [];
id_bc = [];
id_nomesh = [];
id_bsfield = [];
id_pmagnet = [];
id_tconductor = [];
id_tcapacitor = [];
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~isempty(id_mesh2d) || ~isempty(id_dom2d)
    for3d = 0;
end
%--------------------------------------------------------------------------
design3d = [];
id_design3d = [];
if ~isempty(id_emdesign3d)
    design3d = 'emdesign3d';
    id_design3d = id_emdesign3d;
end
if ~isempty(id_thdesign3d)
    design3d = 'thdesign3d';
    id_design3d = id_thdesign3d;
end
%--------------------------------------------------------------------------
thing = [];
id_thing = [];
additional = [];
if ~isempty(id_econductor)
    thing = 'econductor';
    id_thing = id_econductor;
end
if ~isempty(id_mconductor)
    thing = 'mconductor';
    id_thing = id_mconductor;
end
if ~isempty(id_coil)
    thing = 'coil';
    id_thing = id_coil;
end
if ~isempty(id_bc)
    thing = 'bc';
    id_thing = id_bc;
end
if ~isempty(id_nomesh)
    thing = 'nomesh';
    id_thing = id_nomesh;
end
if ~isempty(id_bsfield)
    thing = 'bsfield';
    id_thing = id_bsfield;
end
if ~isempty(id_pmagnet)
    thing = 'pmagnet';
    id_thing = id_pmagnet;
end
if ~isempty(id_tconductor)
    thing = 'tconductor';
    id_thing = id_tconductor;
end
if ~isempty(id_tcapacitor)
    thing = 'tcapacitor';
    id_thing = id_tcapacitor;
end
%--------------------------------------------------------------------------
if ~isempty(design3d)
    id_mesh3d = c3dobj.(design3d).(id_design3d).id_mesh3d;
end
%--------------------------------------------------------------------------
if ~isempty(design3d) && ~isempty(thing)
    id_dom3d  = c3dobj.(design3d).(id_design3d).(thing).(id_thing).id_dom3d;
    % ---
    if strcmpi(thing,'coil')
        additional = c3dobj.(design3d).(id_design3d).(thing).(id_thing);
        additional.type = 'coil';
    end
end
%--------------------------------------------------------------------------
if isempty(id_mesh2d) && isfield(c3dobj,'mesh2d')
    id_mesh2d = fieldnames(c3dobj.mesh2d);
    id_mesh2d = id_mesh2d{1};
end
%--------------------------------------------------------------------------
if isempty(id_mesh3d) && isfield(c3dobj,'mesh3d')
    id_mesh3d = fieldnames(c3dobj.mesh3d);
    id_mesh3d = id_mesh3d{1};
end
%--------------------------------------------------------------------------
if isempty(of_dom3d)
    of_dom3d = id_dom3d;
end
%--------------------------------------------------------------------------
if ~iscell(of_dom3d)
    of_dom3d = {of_dom3d};
end
%--------------------------------------------------------------------------
% --- Output
meshobj.for3d     = for3d;
% ---
meshobj.id_mesh3d = id_mesh3d;
meshobj.id_dom3d  = id_dom3d;
meshobj.of_dom3d  = of_dom3d;
% ---
meshobj.id_mesh2d = id_mesh2d;
meshobj.id_dom2d  = id_dom2d;
% ---
meshobj.additional = additional;
