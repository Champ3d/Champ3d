function [face_in_elem, ori_face_in_elem, sign_face_in_elem] = f_get_face_in_elem(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = f_arglist('get_face_in_elem');

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
    node = mesh3d.node;
    elem = mesh3d.elem;
    defined_on = 'elem';
    %----------------------------------------------------------------------
    if ~isfield(mesh3d,'face')
        face_list = f_face(elem,'defined_on',defined_on);
    elseif isempty(mesh3d.edge)
        face_list = f_face(elem,'defined_on',defined_on);
    else
        face_list = mesh3d.face;
    end
else
    %----------------------------------------------------------------------
    node = mesh3d.node;
    %----------------------------------------------------------------------
    of_dom3d = f_to_scellargin(of_dom3d);
    %----------------------------------------------------------------------
    elem = [];
    for i = 1:length(of_dom3d)
        defined_on = mesh3d.dom3d.(of_dom3d{i}).defined_on;
        if ~any(strcmpi('elem',defined_on))
            error([mfilename ': #of_dom3d list must defined_on elem)!']);
        end
        elem = [elem mesh3d.elem(:,mesh3d.dom3d.(of_dom3d{i}).id_elem)];
    end
    %----------------------------------------------------------------------
    face_list = f_face(elem,'defined_on',defined_on);
    %----------------------------------------------------------------------
end
%--------------------------------------------------------------------------
elem_type = f_elemtype(elem,'defined_on',defined_on);
%--------------------------------------------------------------------------
[face_in_elem, ori_face_in_elem, sign_face_in_elem] = ...
    f_faceinelem(elem,node,face_list,'elem_type',elem_type,'get',get);
%--------------------------------------------------------------------------

end