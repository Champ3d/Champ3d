function geo = f_add_dom2d(geo,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh2d','id_dom2d','id_x','id_y','id_elemdom'};

% --- default input value
id_mesh2d = [];
id_dom2d = [];
id_x = [];
id_y = [];
id_elemdom = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh2d)
    id_mesh2d = fieldnames(geo.geo2d.mesh2d);
    id_mesh2d = id_mesh2d{1};
end

if isempty(id_dom2d)
    error([mfilename ' : #id_dom2d must be given !']);
end

%--------------------------------------------------------------------------
switch geo.geo2d.mesh2d.(id_mesh2d).mesher
    case 'mesh2dgeo1d'
        %------------------------------------------------------------------
        if isempty(id_x) || isempty(id_y)
            error([mfilename ' : #id_x and #id_y must be given !']);
        end
        %------------------------------------------------------------------
        id_x = f_to_dcellargin(id_x);
        id_y = f_to_dcellargin(id_y);
        [id_x, id_y] = f_pairing_cellargin(id_x, id_y);
        %------------------------------------------------------------------
        id_elem_x = [];
        id_elem_y = [];
        for i = 1:length(id_x)
            for j = 1:length(id_x{i})
                id_elem_x = [id_elem_x ...
                       geo.geo2d.mesh2d.(id_mesh2d).(id_x{i}{j}).id_elem];
            end
            for j = 1:length(id_y{i})
                id_elem_y = [id_elem_y ...
                       geo.geo2d.mesh2d.(id_mesh2d).(id_y{i}{j}).id_elem];
            end
        end
        id_elem_x = unique(id_elem_x);
        id_elem_y = unique(id_elem_y);
        %------------------------------------------------------------------
        geo.geo2d.dom2d.(id_dom2d).id_elem = intersect(id_elem_x,id_elem_y);
        %------------------------------------------------------------------
    case 'quadmesh'
    case 'triangle-femm'
end
%--------------------------------------------------------------------------


