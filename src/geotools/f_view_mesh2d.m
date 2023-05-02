function f_view_mesh2d(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh2d','id_dom2d','id_x','id_y','color'};

% --- default input value
id_mesh2d = [];
id_dom2d = [];
id_x = [];
id_y = [];
color = 'w';
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
    id_mesh2d = fieldnames(c3dobj.geo2d.mesh2d);
    id_mesh2d = id_mesh2d{1};
end
if isempty(id_dom2d)
    id_dom2d = {''};
    id_elem = 1:c3dobj.geo2d.mesh2d.(id_mesh2d).nb_elem;
    disptext = {'all-elem'};
else
    id_elem = c3dobj.geo2d.dom2d.(id_dom2d).id_elem;
    disptext = id_dom2d;
end
%--------------------------------------------------------------------------
clear msh;
msh.Vertices = c3dobj.geo2d.mesh2d.(id_mesh2d).node.';
msh.Faces = c3dobj.geo2d.mesh2d.(id_mesh2d).elem(:,id_elem).';
msh.FaceColor = color;
msh.EdgeColor = 'k'; % [0.7 0.7 0.7] --> gray
patch(msh); axis equal; alpha(0.5); hold on
if ~isempty(id_elem)
    node1x = mean(c3dobj.geo2d.mesh2d.(id_mesh2d).node(1, ...
                  c3dobj.geo2d.mesh2d.(id_mesh2d).elem(1:4,id_elem(1))));
    node1y = mean(c3dobj.geo2d.mesh2d.(id_mesh2d).node(2, ...
                  c3dobj.geo2d.mesh2d.(id_mesh2d).elem(1:4,id_elem(1))));
    text(node1x, node1y, disptext, 'color', 'blue', 'HorizontalAlignment', 'center');
end
