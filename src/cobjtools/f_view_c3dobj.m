function f_view_c3dobj(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'face_color','edge_color','alpha_value', 'text_color', 'text_size'...
           'id_mesh2d','id_dom2d',...
           'id_mesh3d','id_dom3d',...
           'id_emdesign3d','id_thdesign3d', ...
           'id_econductor','id_mconducteur','id_coil','id_bc','id_nomesh',...
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
id_mconducteur = [];
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
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
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
if ~isempty(id_econductor)
    thing = 'econductor';
    id_thing = id_econductor;
end
if ~isempty(id_mconducteur)
    thing = 'mconducteur';
    id_thing = id_mconducteur;
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
    thing = 'bs_field';
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
% if ~isempty()
%     thing = '';
%     id_thing = '';
% end
%--------------------------------------------------------------------------
if ~isempty(design3d) && ~isempty(thing)
    id_mesh3d = c3dobj.(design3d).(id_design3d).(thing).(id_thing).id_mesh3d;
    id_dom3d  = c3dobj.(design3d).(id_design3d).(thing).(id_thing).id_dom3d;
end
%--------------------------------------------------------------------------
% if isempty(id_mesh2d) && isempty(id_mesh3d)
%     error([mfilename ' : #id_mesh2d or #id_mesh3d must be given !']);
% end
%--------------------------------------------------------------------------
elem_type = [];
defined_on = 'elem';
if isempty(id_mesh3d) && isempty(id_dom3d)
    if isempty(id_mesh2d)
        id_mesh2d = fieldnames(c3dobj.mesh2d);
        id_mesh2d = id_mesh2d{1};
    end
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
    if isempty(id_mesh3d)
        id_mesh3d = fieldnames(c3dobj.mesh3d);
        id_mesh3d = id_mesh3d{1};
    end
    %----------------------------------------------------------------------
    node = c3dobj.mesh3d.(id_mesh3d).node;
    %----------------------------------------------------------------------
    if ~isempty(id_dom3d)
        disptext = id_dom3d;
        defined_on = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on{1};
        switch defined_on
            case {'elem'}
                id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
                elem    = c3dobj.mesh3d.(id_mesh3d).elem(:,id_elem);
            case {'face'}
                id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_face;
                elem    = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).face;
            case {'edge'}
                id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_edge;
                elem    = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).edge;
            case {'node'}
                id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_node;
                elem    = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).node;
        end
    else
        elem = c3dobj.mesh3d.(id_mesh3d).elem;
        disptext = 'all';
        defined_on = 'elem';
    end
    elem_type = c3dobj.mesh3d.(id_mesh3d).elem_type;
end
%--------------------------------------------------------------------------
if ~isempty(id_mesh2d)
    %----------------------------------------------------------------------
    f_view_mesh2d(c3dobj.mesh2d.(id_mesh2d).node, ...
                  c3dobj.mesh2d.(id_mesh2d).elem(:,id_elem), ...
                  'elem_type',elem_type, ...
                  'face_color',face_color,'edge_color',edge_color,...
                  'alpha_value',alpha_value);
    %----------------------------------------------------------------------
    % Info
    cnode = f_barrycenter(c3dobj.mesh2d.(id_mesh2d).node, ...
                          c3dobj.mesh2d.(id_mesh2d).elem(:,id_elem(1)));
    disptext = strrep(disptext,'_','-');
    text(cnode(1), cnode(2), disptext, 'color', text_color, ...
        'FontSize', text_size,'HorizontalAlignment', 'center');
end
%--------------------------------------------------------------------------
if ~isempty(id_mesh3d)
    %----------------------------------------------------------------------
    f_view_mesh3d(node, elem, ...
                  'elem_type',elem_type, ...
                  'defined_on',defined_on, ...
                  'face_color',face_color,'edge_color',edge_color,...
                  'alpha_value',alpha_value);
    %----------------------------------------------------------------------
    % Info
    cnode = f_barrycenter(node, elem(:,1));
    disptext = strrep(disptext,'_','-');
    text(cnode(1), cnode(2), cnode(3), disptext, 'color', text_color, ...
        'FontSize', text_size, 'HorizontalAlignment', 'center');
end
%--------------------------------------------------------------------------





