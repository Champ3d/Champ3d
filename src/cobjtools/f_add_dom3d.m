function c3dobj = f_add_dom3d(c3dobj,varargin)
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
arglist = {'id_mesh3d','id_dom3d','id_dom2d','id_layer','elem_code', ...
           'defined_on','of_dom3d','dom3d_equation'...
           'get','n_direction','n_component'};

% --- default input value
id_mesh3d = [];
id_dom3d = [];
id_dom2d = [];
id_layer = [];
elem_code = [];
defined_on = 'elem'; % 'face', 'interface', 'bound_face', 'edge', 'bound_edge'
dom3d_equation = [];
of_dom3d = [];
get = [];
n_direction = 'outward';
n_component = []; % 1, 2 or 3
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
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
        if any(strcmpi(mesher,{'c3d_hexamesh','c3d_prismmesh'}))
            f_fprintf(0,'Add #dom3d',1,id_dom3d,0,'in #mesh3d',1,id_mesh3d);
            % ---
            if ~isempty(id_dom2d) && ~isempty(id_layer)
                [id_elem, elem_code] = f_c3d_mesher_find_elem3d(c3dobj, ...
                    'id_mesh3d',id_mesh3d,'id_dom2d',id_dom2d,...
                    'id_layer',id_layer,'elem_code',elem_code);
            else
                id_elem = 1:size(c3dobj.mesh3d.(id_mesh3d).elem, 2);
                elem_code = c3dobj.mesh3d.(id_mesh3d).elem_code;
            end
            % ---
            if ~isempty(dom3d_equation)
                idElem = ...
                    f_find_elem3d(c3dobj.mesh3d.(id_mesh3d).node,...
                     c3dobj.mesh3d.(id_mesh3d).elem(:,id_elem),...
                    'dom3d_equation', dom3d_equation);
                id_elem = id_elem(idElem);
                elem_code = elem_code(idElem);
            end
        end
        %------------------------------------------------------------------
        if any(strcmpi(mesher,{'gmsh'}))
            
        end
        %------------------------------------------------------------------
        % output
        c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on = {'elem',defined_on};
        c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem = id_elem;
        c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).elem_code = elem_code;
        c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).dom3d_equation = dom3d_equation;
        % --- Log message
        f_fprintf(0,'-',1,length(id_elem),0,'elem',0,'--- in',1,toc,0,'s \n');

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
            domlist  = '';
            for i = 1:length(of_dom3d)
                for j = 1:length(of_dom3d{i})
                    domlist = [domlist '#' of_dom3d{i}{j} ' '];
                end
            end
            [bound_face, lid_bound_face, info] = ...
                f_get_bound_face(c3dobj,'id_mesh3d',id_mesh3d,'of_dom3d',of_dom3d,...
                     'get',get,'n_direction',n_direction,'n_component',n_component);
            %--------------------------------------------------------------
            % output
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on = {'face',defined_on};
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).lid_face = lid_bound_face;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).face = bound_face;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_face = ...
                f_findvecnd(bound_face, ...
                            c3dobj.mesh3d.(id_mesh3d).face);
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).info = ...
                           [info ', normal w.r.t dom3d #' domlist];
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
            domlist = ['#' of_dom3d{1}{1}];
            [inter_face, lid_inter_face, info] = ...
                f_get_inter_face(c3dobj,'id_mesh3d',id_mesh3d,'of_dom3d',of_dom3d,...
                     'get',get,'n_direction',n_direction,'n_component',n_component);
            %--------------------------------------------------------------
            % output
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on = {'face',defined_on};
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).lid_face = lid_inter_face;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).face = inter_face;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_face = ...
                f_findvecnd(inter_face, ...
                            c3dobj.mesh3d.(id_mesh3d).face);
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).info = ...
                           ['interface with outward normal to ' domlist];
        end
    case {'edge','bound_edge','ed'}
        if strcmpi(mesher,'c3d_hexamesh')
            
        end
end


