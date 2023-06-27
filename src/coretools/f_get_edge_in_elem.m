function [edge_in_elem, ori_edge_in_elem] = f_get_edge_in_elem(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = f_arglist('get_edge_in_elem');

% --- default input value
get = [];

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
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
    elem = mesh3d.elem;
    defined_on = 'elem';
    %----------------------------------------------------------------------
    if ~isfield(mesh3d,'edge')
        edge_list = f_edge(elem,'defined_on',defined_on);
    elseif isempty(mesh3d.edge)
        edge_list = f_edge(elem,'defined_on',defined_on);
    else
        edge_list = mesh3d.edge;
    end
else
    %----------------------------------------------------------------------
    of_dom3d = f_to_scellargin(of_dom3d);
    %----------------------------------------------------------------------
    elem = [];
    for i = 1:length(of_dom3d)
        defined_on = mesh3d.dom3d.(of_dom3d{i}).defined_on;
        if ~any(strcmpi('elem',defined_on))
            error([mfilename ': #of_dom3d list must defined_on elem !']);
        end
        elem = [elem mesh3d.elem(:,mesh3d.dom3d.(of_dom3d{i}).id_elem)];
    end
    %----------------------------------------------------------------------
    elem_type = f_elemtype(mesh3d.elem,'defined_on',defined_on);
    %----------------------------------------------------------------------
    edge_list = f_edge(elem,'elem_type',elem_type);
    %----------------------------------------------------------------------
end
%--------------------------------------------------------------------------
elem_type = f_elemtype(elem,'defined_on',defined_on);
%--------------------------------------------------------------------------
[edge_in_elem, ori_edge_in_elem] = ...
    f_edgeinelem(elem,edge_list,'elem_type',elem_type,'get',get);
%--------------------------------------------------------------------------
% --- Outputs
% mesh3d.edge_in_elem = edge_in_elem;
% mesh3d.ori_edge_in_elem = ori_edge_in_elem;

end