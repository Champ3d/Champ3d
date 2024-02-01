function [id_edge_in_face, sign_edge_in_face] = f_get_edge_in_face(c3dobj,varargin)
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
arglist = {'id_mesh2d','id_dom2d',...
           'id_mesh3d','id_dom3d',...
           'of_dom3d',...
           'id_emdesign3d','id_thdesign3d', ...
           'id_econductor','id_mconductor',...
           'id_coil','id_bc','id_nomesh',...
           'id_bsfield','id_pmagnet',...
           'id_tconductor','id_tcapacitor',...
           'get',...
           'n_direction','n_component', ...
           'for3d'};

% --- default input value
get = [];

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
meshobj   = f_get_meshobj(c3dobj,varargin{:});
id_mesh3d = meshobj.id_mesh3d;
of_dom3d  = meshobj.of_dom3d;
%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    error([mfilename ': no mesh3d found !']);
else
    mesh3d = c3dobj.mesh3d.(id_mesh3d);
end
%--------------------------------------------------------------------------
if f_isempty(of_dom3d)
    face = mesh3d.face;
    defined_on = 'face';
    %----------------------------------------------------------------------
    elem_type = f_elemtype(face,'defined_on',defined_on);
    %----------------------------------------------------------------------
    if ~isfield(mesh3d,'edge')
        edge_list = f_edge(face,'elem_type',elem_type);
    elseif isempty(mesh3d.edge)
        edge_list = f_edge(face,'elem_type',elem_type);
    else
        edge_list = mesh3d.edge;
    end
    %----------------------------------------------------------------------
else
    %----------------------------------------------------------------------
    of_dom3d = f_to_scellargin(of_dom3d);
    %----------------------------------------------------------------------
    face = [];
    for i = 1:length(of_dom3d)
        defined_on = mesh3d.dom3d.(of_dom3d{i}).defined_on;
        if ~any(strcmpi('face',defined_on))
            error([mfilename ': #of_dom3d list must defined_on face !']);
        end
        face = [face mesh3d.face(:,mesh3d.dom3d.(of_dom3d{i}).id_face)];
    end
    %----------------------------------------------------------------------
    elem_type = f_elemtype(face,'defined_on',defined_on);
    %----------------------------------------------------------------------
    edge_list = f_edge(face,'elem_type',elem_type);
    %----------------------------------------------------------------------
end
%--------------------------------------------------------------------------
elem_type = f_elemtype(face,'defined_on',defined_on);
%--------------------------------------------------------------------------
[id_edge_in_face, sign_edge_in_face] = ...
    f_edgeinface(face,edge_list,'get',get);
%--------------------------------------------------------------------------
end