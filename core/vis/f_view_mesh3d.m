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
arglist = {'elem_type','defined_on','face_color','edge_color','alpha_value',...
           'options'};

% --- default input value
elem_type   = '';
defined_on  = 'elem'; % elem, face, edge, 'node'
edge_color  = 'k';
face_color  = 'c';
alpha_value = 0.9;
options     = ''; 
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
    itria = find(face(end, id_face) == 0);
    if ~isempty(itria)
        triface  = face(1:3,id_face(itria));
        f_view_face(node, triface, transarg{:}); hold on
    end
    % ---
    % 2/ quad
    iquad = find(face(end, id_face) ~= 0);
    if ~isempty(iquad)
        quadface = face(1:4,id_face(iquad));
        f_view_face(node, quadface, transarg{:}); hold on
    end
    view(3);
    %----------------------------------------------------------------------
elseif any(f_strcmpi(defined_on,{'face'}))    
    %----------------------------------------------------------------------
    maxnbNo_inEl = size(elem,1);
    nb_elem = size(elem,2);
    %----------------------------------------------------------------------
    itria = [];
    iquad = [];
    if maxnbNo_inEl == 3
        itria = 1:nb_elem;
        iquad = [];
    elseif maxnbNo_inEl == 4
        itria = find(elem(4,:) == 0);
        iquad = setdiff(1:nb_elem,itria);
    end
    %----------------------------------------------------------------------
    % 1/ triangle
    if ~isempty(itria)
        triface  = elem(1:3,itria);
        f_view_face(node, triface, transarg{:}); hold on
    end
    % ---
    % 2/ quad
    if ~isempty(iquad)
        quadface  = elem(1:4,iquad);
        f_view_face(node, quadface, transarg{:}); hold off
    end
    view(3);
    %----------------------------------------------------------------------
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
%--------------------------------------------------------------------------
if any(f_strcmpi(options,{'show_id_node'}))
    id_node = f_uniquenode(elem);
    nb_node = length(id_node);
    x = node(1,id_node);
    y = node(2,id_node);
    showtext = cell(1,nb_node);
    for i = 1:nb_node
        showtext{i} = num2str(id_node(i));
    end
    % ---
    hold on;
    if size(node,1) == 2
        text(x,y,showtext,'FontSize',10,'Color','blue');
    elseif size(node,1) > 2
        z = node(3,id_node);
        text(x,y,z,showtext,'FontSize',10,'Color','blue');
    end
end
%--------------------------------------------------------------------------
c3name = '$\overrightarrow{champ}{3d}$';
c3_already = 0;
%--------------------------------------------------------------------------
ztchamp3d = findobj(gcf, 'Type', 'Text');
if isfield(ztchamp3d,'String')
    ztchamp3d = ztchamp3d.String;
    if iscell(ztchamp3d)
        for i = 1:length(ztchamp3d)
            if strcmpi(ztchamp3d{i},c3name)
                c3_already = 1;
            end
        end
    elseif ischar(ztchamp3d)
        if strcmpi(ztchamp3d,c3name)
            c3_already = 1;
        end
    end
end
%--------------------------------------------------------------------------
if ~c3_already
    texpos = get(gca, 'OuterPosition');
    hold on;
    text(texpos(1),texpos(2)+1.05, ...
         c3name, ...
         'FontSize',10, ...
         'FontWeight','bold',...
         'Color','blue', ...
         'Interpreter','latex',...
         'Units','normalized', ...
         'VerticalAlignment', 'baseline', ...
         'HorizontalAlignment', 'right');
end
%--------------------------------------------------------------------------