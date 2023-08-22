function c3dobj = f_build_airbox(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_airbox'};

% --- default input value
id_emdesign3d = [];
id_airbox = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_emdesign3d)
    error([mfilename ': #id_emdesign3d must be given']); 
end
%--------------------------------------------------------------------------
if iscell(id_emdesign3d)
    id_emdesign3d = id_emdesign3d{1};
end
%--------------------------------------------------------------------------
if isempty(id_airbox)
    if isfield(c3dobj.emdesign3d.(id_emdesign3d),'airbox')
        id_airbox_ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).airbox);
        for iab = 1:length(id_airbox_)
            if ~strcmpi(id_airbox_{iab},'airbox_by_default')
                id_airbox = id_airbox_{iab};
                break; % take the first not by default
            end
        end
    end
end
%--------------------------------------------------------------------------
if isempty(id_airbox)
    id_airbox = 'airbox_by_default';
    c3dobj = f_add_dom3d(c3dobj,'id_dom3d','airbox_by_default');
    c3dobj = f_add_airbox(c3dobj,'id_emdesign3d',id_emdesign3d,...
                          'id_airbox',id_airbox, ...
                          'id_dom3d','airbox_by_default','a_value',0);
end
%--------------------------------------------------------------------------
id_airbox = f_to_scellargin(id_airbox);
id_airbox = id_airbox{1}; % cannot treat two airbox
%----------------------------------------------------------------------
em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
%----------------------------------------------------------------------
fprintf(['Build airbox ' id_airbox ...
         ' in emdesign3d #' id_emdesign3d ...
         ' for ' em_model]);
switch em_model
    case {'aphijw','aphits'}
        tic;
        %------------------------------------------------------------------
        id_mesh3d = c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d;
        %------------------------------------------------------------------
        phydomobj = c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox);
        %------------------------------------------------------------------
        id_dom3d  = phydomobj.id_dom3d;
        defined_on = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on;
        if any(strcmpi(defined_on,'elem'))
            id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
        elseif any(strcmpi(defined_on,'face'))
            return;
            % TODO
            % id_face = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_face;
        end
        %------------------------------------------------------------------
        edge_list = c3dobj.mesh3d.(id_mesh3d).edge;
        %------------------------------------------------------------------
        bound_face = f_get_bound_face(c3dobj,'of_dom3d',id_dom3d);
        %------------------------------------------------------------------
        %id_edge_in_bound_face = f_edgeinelem(bound_face,edge_list,'defined_on','face');
        id_edge_in_bound_face = f_edgeinface(bound_face,edge_list);
        id_edge_in_bound_face = unique(id_edge_in_bound_face);
        %------------------------------------------------------------------
        elem = c3dobj.mesh3d.(id_mesh3d).elem(:,id_elem);
        id_edge_in_elem = f_edgeinelem(elem,edge_list);
        id_edge_in_elem = unique(id_edge_in_elem);
        %------------------------------------------------------------------
        id_inner_edge = setdiff(id_edge_in_elem,id_edge_in_bound_face);
        id_bound_edge = id_edge_in_bound_face;
        %------------------------------------------------------------------
        % --- Output
        c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox).(em_model).id_elem = id_elem;
        c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox).(em_model).id_inner_edge = id_inner_edge;
        c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox).(em_model).id_bound_edge = id_bound_edge;
        % --- Log message
        fprintf(' --- in %.2f s \n',toc);
    case {'tomejw','tomets'}
        % TODO
end
%----------------------------------------------------------------------