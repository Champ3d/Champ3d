function f_view_mesh3d(node,elem,varargin)
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
arglist = {'elem_type','defined_on','face_color','edge_color','alpha_value'};

% --- default input value
elem_type   = '';
defined_on  = 'elem'; % elem, face, edge, 'node'
edge_color  = 'k';
face_color  = 'c';
alpha_value = 0.9;
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if any(f_strcmpi(defined_on,{'elem','face'}))
    elem_type = f_elemtype(elem,'defined_on',defined_on);
end
%--------------------------------------------------------------------------
transarg = {'edge_color',edge_color,'face_color',face_color,'alpha_value',alpha_value};
%--------------------------------------------------------------------------
if any(f_strcmpi(defined_on,{'elem'}))
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
elseif any(f_strcmpi(defined_on,{'face'}))
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
elseif any(f_strcmpi(defined_on,{'edge'}))
    % --- TODO
elseif any(f_strcmpi(defined_on,{'node'}))
    % ---
    if size(node,1) == 2
        plot(node(1,elem),node(2,elem),['o' face_color],'MarkerFaceColor',face_color);
        axis tight; axis equal; box on;
        xlabel('x (m)'); ylabel('y (m)');
    elseif size(node,1) == 3
        plot3(node(1,elem),node(2,elem),node(3,elem),['o' face_color],'MarkerFaceColor',face_color);
        axis tight; axis equal; box on; view(3);
        xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); 
    end
end