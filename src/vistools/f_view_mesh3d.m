function f_view_mesh3d(node,elem,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type','defined_on','face_color','edge_color','alpha_value'};

% --- default input value
elem_type   = '';
defined_on  = 'elem'; % elem, face, edge
edge_color  = 'none';
face_color  = 'w';
alpha_value = 1;
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
elem_type = f_elemtype(elem,'defined_on',defined_on);
%--------------------------------------------------------------------------
transarg = {'edge_color',edge_color,'face_color',face_color,'alpha_value',alpha_value};
%--------------------------------------------------------------------------
switch defined_on
    case {'elem'}
        % ---
        %mshds.node = node;
        %mshds.elem = elem;
        %mshds = f_meshds3d(mshds,'output_list','face');
        %mshds = f_get_bound_face(mshds,'elem_type',elem_type);
        % ---
        %face_in_elem = mshds.face_in_elem;
        %face = mshds.face;
        %id_face = reshape(face_in_elem, 1, []);
        %id_face = unique(id_face);
        % ---
        face = f_boundface(elem,node,'elem_type',elem_type);
        id_face = 1:size(face,2);
        % ---
        % 1/ triangle
        ind_tria = find(face(end, id_face) == 0);
        if ~isempty(ind_tria)
            triface  = face(1:3,id_face(ind_tria));
            f_view_face(node, triface, transarg{:}); hold on
        end
        % ---
        % 2/ quad
        ind_quad = find(face(end, id_face) ~= 0);
        if ~isempty(ind_quad)
            quadface = face(1:4,id_face(ind_quad));
            f_view_face(node, quadface, transarg{:}); hold on
        end
        view(3);
    case {'face'}
        id_face = 1:size(elem, 2);
        % 1/ triangle
        ind_tria = find(elem(end, :) == 0);
        if ~isempty(ind_tria)
            triface  = elem(1:3,ind_tria);
            f_view_face(node, triface, transarg{:}); hold on
        end
        % ---
        % 2/ quad
        ind_quad = setdiff(id_face, ind_tria);
        if ~isempty(ind_quad)
            quadface  = elem(1:4,ind_quad);
            f_view_face(node, quadface, transarg{:}); hold off
        end
        view(3);
    case {'edge'}
end