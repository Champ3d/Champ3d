function c3dobj = f_add_fixed_bc(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_thdesign3d','id_bc','id_dom3d','defined_on','bc_value'};

% --- default input value
id_emdesign3d = [];
id_thdesign3d = [];
id_dom3d = [];
id_bc = [];
defined_on = [];
bc_value = 0;
%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No bc to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
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
if ~isempty(id_emdesign3d)
    design3d = 'emdesign3d';
    id_design3d = id_emdesign3d;
elseif ~isempty(id_thdesign3d)
    design3d = 'thdesign3d';
    id_design3d = id_thdesign3d;
end
%--------------------------------------------------------------------------
% --- Output
c3dobj.(design3d).(id_design3d).bc.(id_bc).id_dom3d = id_dom3d;
c3dobj.(design3d).(id_design3d).bc.(id_bc).bc_type = 'fixed';
c3dobj.(design3d).(id_design3d).bc.(id_bc).defined_on = defined_on;
c3dobj.(design3d).(id_design3d).bc.(id_bc).bc_value = bc_value;
% --- info message
fprintf(['Add fixed boundary condition #' id_bc ' to ' design3d ' #' id_design3d '\n']);


