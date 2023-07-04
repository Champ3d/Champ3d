function c3dobj = f_add_neumann_bc(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_thdesign3d','id_bc','id_mesh3d','id_dom3d','defined_on','bc_coef'};

% --- default input value
id_emdesign3d = [];
id_thdesign3d = [];
id_mesh3d     = [];
id_dom3d      = [];
id_bc         = [];
defined_on    = []; % 'edge_bound', 'face_bound', 'edge', 'face'
bc_coef       = 0;
%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No bc to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------

if isempty(id_emdesign3d) && isempty(id_thdesign3d)
    error([mfilename ': id_emdesign3d or id_thdesign3d must be given !'])
    %id_emdesign3d = fieldnames(c3dobj.emdesign3d);
    %id_emdesign3d = id_emdesign3d{1};
end

if isempty(id_bc)
    error([mfilename ': id_bc must be defined !'])
end

if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be given !'])
end

%--------------------------------------------------------------------------
% --- Output
if ~isempty(id_emdesign3d)
    design3d = 'emdesign3d';
    id_design3d = id_emdesign3d;
elseif ~isempty(id_thdesign3d)
    design3d = 'thdesign3d';
    id_design3d = id_thdesign3d;
end
%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    id_mesh3d = c3dobj.(design3d).(id_design3d).id_mesh3d;
    id_mesh3d = id_mesh3d{1};
end
%--------------------------------------------------------------------------
% --- Output
c3dobj.(design3d).(id_design3d).bc.(id_bc).id_mesh3d = id_mesh3d;
c3dobj.(design3d).(id_design3d).bc.(id_bc).id_dom3d = id_dom3d;
c3dobj.(design3d).(id_design3d).bc.(id_bc).bc_type = 'neumann';
c3dobj.(design3d).(id_design3d).bc.(id_bc).defined_on = defined_on;
c3dobj.(design3d).(id_design3d).bc.(id_bc).bc_value = bc_coef;
% --- info message
fprintf(['Add neumann boundary condition #' id_bc ' to ' design3d ' #' id_design3d ' in mesh3d #' id_mesh3d '\n']);

