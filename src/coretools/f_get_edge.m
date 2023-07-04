function edge = f_get_edge(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = f_arglist('getedge');

% --- default input value


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
    elem = mesh3d.elem;
    defined_on = 'elem';
else
    %----------------------------------------------------------------------
    of_dom3d = f_to_scellargin(of_dom3d);
    %----------------------------------------------------------------------
    elem = [];
    for i = 1:length(of_dom3d)
        doncheck = mesh3d.dom3d.(of_dom3d{1}).defined_on;
        defined_on = mesh3d.dom3d.(of_dom3d{i}).defined_on;
        if ~any(strcmpi(doncheck,defined_on))
            error([mfilename ': #of_dom3d list must defined_on same type (elem, face)!']);
        end
        if any(strcmpi(defined_on,'elem'))
            elem = [elem mesh3d.elem(:,mesh3d.dom3d.(of_dom3d{i}).id_elem)];
        elseif any(strcmpi(defined_on,'face'))
            elem = [elem mesh3d.face(:,mesh3d.dom3d.(of_dom3d{i}).id_face)];
        end
    end
end
%--------------------------------------------------------------------------
elem_type = f_elemtype(elem,'defined_on',defined_on);
%--------------------------------------------------------------------------
edge = f_edge(elem,'elem_type',elem_type);
%--------------------------------------------------------------------------
% --- Outputs
% if isempty(of_dom3d)
%     mesh3d.edge = edge;
% else
%     for i = 1:length(of_dom3d)
%         mesh3d.dom3d.(of_dom3d{i}).edge = edge;
%     end
% end
%--------------------------------------------------------------------------
end