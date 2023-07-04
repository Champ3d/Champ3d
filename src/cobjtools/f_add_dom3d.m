function c3dobj = f_add_dom3d(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','id_dom3d','id_dom2d','id_layer','elem_code',...
           'defined_on','of_dom3d','n_direction'};

% --- default input value
id_mesh3d = [];
id_dom3d = [];
id_dom2d = [];
id_layer = [];
elem_code = [];
defined_on = 'elem'; % 'face', 'interface', 'bound_face', 'edge', 'bound_edge'
of_dom3d = [];
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    id_mesh3d = fieldnames(c3dobj.mesh3d);
    id_mesh3d = id_mesh3d{1};
end

if isempty(id_dom3d)
    error([mfilename ' : #id_dom3d must be given !']);
end
%--------------------------------------------------------------------------
% output 1
c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on = defined_on;
%--------------------------------------------------------------------------
mesher = c3dobj.mesh3d.(id_mesh3d).mesher;
switch defined_on
    case {'elem','el'}
        %------------------------------------------------------------------
        if strcmpi(mesher,'c3d_hexamesh')
            fprintf(['Add dom3d #' id_dom3d ' in mesh3d #' id_mesh3d]);
            [id_elem, elem_code] = f_c3d_mesher_find_elem3d(c3dobj, ...
                'id_mesh3d',id_mesh3d,'id_dom2d',id_dom2d,...
                'id_layer',id_layer,'elem_code',elem_code);
        end
        %------------------------------------------------------------------
        if strcmpi(mesher,'c3d_prismmesh')
            fprintf(['Add dom3d #' id_dom3d ' in mesh3d #' id_mesh3d]);
            [id_elem, elem_code] = f_c3d_mesher_find_elem3d(c3dobj, ...
                'id_mesh3d',id_mesh3d,'id_dom2d',id_dom2d,...
                'id_layer',id_layer,'elem_code',elem_code);
        end
        %------------------------------------------------------------------
        if strcmpi(mesher,'gmsh')
            
        end
        %------------------------------------------------------------------
        % output
        c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on = {'elem',defined_on};
        c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem = id_elem;
        c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).elem_code = elem_code;
    case {'face','fa'}
        if strcmpi(mesher,'c3d_hexamesh')
            
        end
    case {'bound_face','boundface'}
        %------------------------------------------------------------------
        if ~isfield(c3dobj.mesh3d.(id_mesh3d).dom3d, of_dom3d)
            error([mfilename ' : no dom3d #' of_dom3d ' exists !']);
        else
            %--------------------------------------------------------------
            of_dom3d = f_to_dcellargin(of_dom3d);
            %--------------------------------------------------------------
            msh.node = c3dobj.mesh3d.(id_mesh3d).node;
            msh.elem = [];
            domlist  = '';
            for i = 1:length(of_dom3d)
                for j = 1:length(of_dom3d{i})
                    msh.elem = [msh.elem ...
                                c3dobj.mesh3d.(id_mesh3d).elem(:,...
                                c3dobj.mesh3d.(id_mesh3d).dom3d.(of_dom3d{i}{j}).id_elem)];
                    domlist = [domlist '#' of_dom3d{i}{j} ' '];
                end
            end
            msh = f_get_bound_face(msh);
            %--------------------------------------------------------------
            % output
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on = {'face',defined_on};
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).lid_face = msh.lid_bound_face;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).face = msh.bound_face;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_face = ...
                f_findvecnd(msh.bound_face, ...
                            c3dobj.mesh3d.(id_mesh3d).face);
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).info = ...
                           [msh.info ', normal w.r.t dom3d #' domlist];
            %c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).elem_code = elem_code;
        end
    case {'interface'}
        if ~isfield(c3dobj.mesh3d.(id_mesh3d).dom3d, of_dom3d)
            error([mfilename ' : no dom3d #' of_dom3d ' exists !']);
        else
            %--------------------------------------------------------------
            if ~iscell(of_dom3d)
                error([mfilename ' : of_dom3d must be like {''a'',''b''}, {''a'',{''b'',''c''}} !']);
            else
                of_dom3d = f_to_dcellargin(of_dom3d,'forced','on');
            end
            %--------------------------------------------------------------
            msh.node = c3dobj.mesh3d.(id_mesh3d).node;
            msh.elem = c3dobj.mesh3d.(id_mesh3d).elem;
            msh.dom3d = c3dobj.mesh3d.(id_mesh3d).dom3d;
            domlist = ['#' of_dom3d{1}{1}];
            msh = f_get_inter_face(msh,'of_dom3d',of_dom3d);
            %--------------------------------------------------------------
            % output
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on = {'face',defined_on};
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_face = msh.id_inter_face;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).face = msh.inter_face;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).info = ...
                           ['interface with outward normal to ' domlist];
        end
    case {'edge','bound_edge','ed'}
        if strcmpi(mesher,'c3d_hexamesh')
            
        end
end


