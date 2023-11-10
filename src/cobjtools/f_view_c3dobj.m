function f_view_c3dobj(c3dobj,varargin)
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
arglist = {'face_color','edge_color','alpha_value', 'text_color', 'text_size'...
           'id_mesh2d','id_dom2d',...
           'id_mesh3d','id_dom3d',...
           'id_emdesign3d','id_thdesign3d', ...
           'id_econductor','id_mconductor','id_coil','id_bc','id_nomesh',...
           'id_bsfield','id_pmagnet',...
           'id_tconductor','id_tcapacitor'};

% --- default input value
id_mesh2d  = [];
id_dom2d   = [];
id_mesh3d  = [];
id_dom3d   = [];
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
edge_color = 'k'; % [0.7 0.7 0.7] --> gray
face_color = 'w';
alpha_value = 1;
text_color = 'k';
text_size = 14;
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
meshobj = f_get_meshobj(c3dobj,varargin{:});
id_mesh3d = meshobj.id_mesh3d;
id_dom3d  = meshobj.id_dom3d;
id_mesh2d = meshobj.id_mesh2d;
id_dom2d  = meshobj.id_dom2d;
for3d     = meshobj.for3d;
additional= meshobj.additional;
%--------------------------------------------------------------------------
elem_type = [];
defined_on = [];
if ~for3d
    %----------------------------------------------------------------------
    if isempty(id_dom2d)
        id_dom2d = {''};
        id_elem  = 1:c3dobj.mesh2d.(id_mesh2d).nb_elem;
        disptext = {'all-elem'};
    else
        id_elem  = c3dobj.mesh2d.(id_mesh2d).dom2d.(id_dom2d).id_elem;
        disptext = id_dom2d;
    end
    %----------------------------------------------------------------------
    elem_type = c3dobj.mesh2d.(id_mesh2d).elem_type;
    %----------------------------------------------------------------------
else
    %----------------------------------------------------------------------
    node = c3dobj.mesh3d.(id_mesh3d).node;
    %----------------------------------------------------------------------
    if ~isempty(id_dom3d)
        disptext = id_dom3d;
        defined_on = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on;
        if any(f_strcmpi(defined_on,'elem'))
            id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
            elem    = c3dobj.mesh3d.(id_mesh3d).elem(:,id_elem);
            defined_on = 'elem';
        elseif any(f_strcmpi(defined_on,'face'))
            id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_face;
            elem    = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).face;
            defined_on = 'face';
        elseif any(f_strcmpi(defined_on,'edge'))
            id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_edge;
            elem    = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).edge;
            defined_on = 'edge';
        elseif any(f_strcmpi(defined_on,'node'))
            id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_node;
            elem    = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).node;
            defined_on = 'node';
        end
    else
        elem = c3dobj.mesh3d.(id_mesh3d).elem;
        disptext = 'all';
        defined_on = 'elem';
    end
    elem_type = c3dobj.mesh3d.(id_mesh3d).elem_type;
end
%--------------------------------------------------------------------------
if ~for3d
    %----------------------------------------------------------------------
    f_view_mesh3d(c3dobj.mesh2d.(id_mesh2d).node, ...
                  c3dobj.mesh2d.(id_mesh2d).elem(:,id_elem), ...
                  'defined_on','face', ...
                  'elem_type',elem_type, ...
                  'face_color',face_color,'edge_color',edge_color,...
                  'alpha_value',alpha_value); hold on
    view(2);
    %----------------------------------------------------------------------
    % Info
    cnode = f_barrycenter(c3dobj.mesh2d.(id_mesh2d).node, ...
                          c3dobj.mesh2d.(id_mesh2d).elem(:,id_elem(1)));
    disptext = strrep(disptext,'_','-');
    text(cnode(1), cnode(2), disptext, 'color', text_color, ...
        'FontSize', text_size,'HorizontalAlignment', 'center');
end
%--------------------------------------------------------------------------
if for3d
    %----------------------------------------------------------------------
    f_view_mesh3d(node, elem, ...
                  'elem_type',elem_type, ...
                  'defined_on',defined_on, ...
                  'face_color',face_color,'edge_color',edge_color,...
                  'alpha_value',alpha_value); hold on
    %----------------------------------------------------------------------
    if ~isempty(additional)
        if strcmpi(additional.type,'coil')
            % ---
            defined_on = 'elem';
            addelem = c3dobj.mesh3d.(id_mesh3d).elem(:,additional.petrode.id_elem);
            f_view_mesh3d(node, addelem, ...
                  'defined_on',defined_on, ...
                  'face_color','r','edge_color','r',...
                  'alpha_value',0.2); hold on
            % ---
            defined_on = 'elem';
            addelem = c3dobj.mesh3d.(id_mesh3d).elem(:,additional.netrode.id_elem);
            f_view_mesh3d(node, addelem, ...
                  'defined_on',defined_on, ...
                  'face_color','b','edge_color','b',...
                  'alpha_value',0.2); hold on
            % ---
            defined_on = 'node';
            addelem = additional.petrode.id_node;
            f_view_mesh3d(node, addelem, ...
                  'defined_on',defined_on, ...
                  'face_color','r','edge_color','r',...
                  'alpha_value',0.2); hold on
            % ---
            defined_on = 'node';
            addelem = additional.netrode.id_node;
            f_view_mesh3d(node, addelem, ...
                  'defined_on',defined_on, ...
                  'face_color','b','edge_color','b',...
                  'alpha_value',0.2); hold on
        end
    end
    %----------------------------------------------------------------------
    % Info
    cnode = f_barrycenter(node, elem(:,1));
    disptext = strrep(disptext,'_','-');
    text(cnode(1), cnode(2), cnode(3), disptext, 'color', text_color, ...
        'FontSize', text_size, 'HorizontalAlignment', 'center');
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



