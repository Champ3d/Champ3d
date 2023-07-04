function [id_edge_in_face, sign_edge_in_face] = f_get_edge_in_face(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = f_arglist('get_edge_in_face');

% --- default input value
get = [];

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
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
    if ~isfield(mesh3d,'edge')
        edge_list = f_edge(face,'defined_on',defined_on);
    elseif isempty(mesh3d.edge)
        edge_list = f_edge(face,'defined_on',defined_on);
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
    edge_list = f_edge(face,'defined_on',defined_on);
    %----------------------------------------------------------------------
end
%--------------------------------------------------------------------------
elem_type = f_elemtype(face,'defined_on',defined_on);
%--------------------------------------------------------------------------
[id_edge_in_face, sign_edge_in_face] = ...
    f_edgeinface(face,edge_list,'elem_type',elem_type,'get',get);
%--------------------------------------------------------------------------
end