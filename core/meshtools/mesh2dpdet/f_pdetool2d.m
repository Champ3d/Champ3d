function c3dobj = f_pdetool2d(c3dobj,varargin)
% F_PDETOOL2D ...
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh2d','centering','origin_coordinates',...
           'shape2d','hgrad','hmax','box','init','jiggle','jiggleiter','mesherversion',...
           'id_dom2refine'};

% --- default input value
id_mesh2d = [];
shape2d = [];
hgrad = 1.3;
hmax = 1;
box  = 'off';
init = 'off';
jiggle = 'mean';
jiggleiter = 10;
mesherversion = 'R2013a';
id_dom2refine = [];
centering = [];
origin_coordinates = [0, 0];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isfield(shape2d,'geoIn')
    switch shape2d.geoIn.type
        case 'geofromdom'
            dgeo = decsg(shape2d.geoIn.geo,['(' shape2d.geoIn.form ')'],shape2d.geoIn.dName.');
        case 'geofromedge'
            dgeo = shape2d.geoIn.dgeo;
    end
else
    error([mfilename ': dom2D geometry input is not defined!']);
end
%--------------------------------------------------------------------------
[node,eb,elem]=initmesh(dgeo,'Hgrad',hgrad,'Hmax',hmax,'Box',box,...
                         'Init',init,'Jiggle',jiggle,...
                         'JiggleIter',jiggleiter,'MesherVersion',mesherversion);
%--------------------------------------------------------------------------
all_id_dom = unique(elem(4,:));
%--------------------------------------------------------------------------
if ~isempty(id_dom2refine)
    for i = 1:length(id_dom2refine)
        if any(all_id_dom == id_dom2refine(i))
            [node,eb,elem]=refinemesh(dgeo,node,eb,elem,id_dom2refine(i));
        end
    end
end
%--------------------------------------------------------------------------
%----- check and correct mesh
[node,elem]=f_reorg2d(node,elem);

%----- centering
if f_istrue(centering)
    node(1,:) = node(1,:) - mean(node(1,:));
    node(2,:) = node(2,:) - mean(node(2,:));
end
%--------------------------------------------------------------------------
c3dobj.mesh2d.(id_mesh2d).mesher = 'pdetool';
c3dobj.mesh2d.(id_mesh2d).dgeo = dgeo;
c3dobj.mesh2d.(id_mesh2d).node = node;
c3dobj.mesh2d.(id_mesh2d).nb_node = size(node,2);
c3dobj.mesh2d.(id_mesh2d).elem = elem(1:3,:);
c3dobj.mesh2d.(id_mesh2d).nb_elem = size(elem,2);
c3dobj.mesh2d.(id_mesh2d).elem_code = elem(4,:);
c3dobj.mesh2d.(id_mesh2d).elem_type = 'tri';
c3dobj.mesh2d.(id_mesh2d).origin_coordinates = origin_coordinates;

end
