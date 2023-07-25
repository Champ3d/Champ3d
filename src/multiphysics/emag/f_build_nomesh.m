function c3dobj = f_build_nomesh(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_nomesh'};

% --- default input value
id_emdesign3d = [];
id_nomesh = '_all';

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
id_nomesh = f_to_scellargin(id_nomesh);
%--------------------------------------------------------------------------
if any(strcmpi(id_nomesh,{'_all'}))
    id_nomesh = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).nomesh);
end
%--------------------------------------------------------------------------
for iec = 1:length(id_nomesh)
    %----------------------------------------------------------------------
    em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
    %----------------------------------------------------------------------
    fprintf(['Building nomesh ' id_nomesh{iec} ...
             ' in emdesign3d #' id_emdesign3d ...
             ' for ' em_model]);
    switch em_model
        case {'aphijw','aphits'}
            tic;
            %--------------------------------------------------------------
            id_mesh3d = c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d;
            %--------------------------------------------------------------
            phydomobj = c3dobj.emdesign3d.(id_emdesign3d).nomesh.(id_nomesh{iec});
            %--------------------------------------------------------------
            id_dom3d  = phydomobj.id_dom3d;
            defined_on = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on;
            if any(strcmpi(defined_on,'elem'))
                id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
            elseif any(strcmpi(defined_on,'face'))
                % TODO
                % id_face = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_face;
            end
            %--------------------------------------------------------------
            nb_elem   = length(id_elem);
            %--------------------------------------------------------------
            edge_list = f_edge(face,'defined_on',defined_on);
            [id_edge_in_face, sign_edge_in_face] = ...
                f_edgeinface(face,edge_list,'elem_type',elem_type,'get',get);
            %--------------------------------------------------------------
            % --- Output
            c3dobj.emdesign3d.(id_emdesign3d).nomesh.(id_nomesh{iec}).aphijw.id_elem = id_elem;
            c3dobj.emdesign3d.(id_emdesign3d).nomesh.(id_nomesh{iec}).aphijw.id_inner_edge = id_inner_edge;
            % --- Log message
            fprintf(' --- in %.2f s \n',toc);
        case {'tomejw','tomets'}
            % TODO
    end
end












