function iso_array = f_evalisofun(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'phydomobj','iso_function'};

% --- default input value
phydomobj = [];
iso_function = [];

% --- default output value
iso_array = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isfield(phydomobj,'id_emdesign3d')
    id_emdesign3d = phydomobj.id_emdesign3d;
    id_mesh3d = c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d;
elseif isfield(phydomobj,'id_thdesign3d')
    id_thdesign3d = phydomobj.id_thdesign3d;
    id_mesh3d = c3dobj.thdesign3d.(id_thdesign3d).id_mesh3d;
end
%--------------------------------------------------------------------------
id_dom3d  = phydomobj.id_dom3d;
id_elem   = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
nb_elem   = length(id_elem);
%--------------------------------------------------------------------------
paramtype = f_paramtype(iso_function);
%--------------------------------------------------------------------------
if ~any(strcmpi(paramtype,{'c3d_parameter_function'}))
    fprintf([mfilename ' : this iso_function is not supported. Use f_make_parameter ! \n']);
    return
end
%--------------------------------------------------------------------------
nb_fargin = nargin(iso_function.f);
%--------------------------------------------------------------------------
alist = {};
for ial = 1:nb_fargin
    %alist{ial} = ['c3dobj' ...
    %              '.' iso_function.from{ial} ...
    %              '.' iso_function.id_cobj{ial} ...
    %              '.' iso_function.field{ial}];
    alist{ial} = iso_function.depend_on{ial};
end
%--------------------------------------------------------------------------
for ial = 1:nb_fargin
    argu{ial} = eval([alist{ial} '(:,id_elem);']);
end
%--------------------------------------------------------------------------
if nb_fargin == 0
    param = feval(iso_function.f);
elseif nb_fargin == 1
    param = feval(iso_function.f,argu{1});
elseif nb_fargin == 2
    param = feval(iso_function.f,argu{1},argu{2});
elseif nb_fargin == 3
    param = feval(iso_function.f,argu{1},argu{2},argu{3});
elseif nb_fargin == 4
    param = feval(iso_function.f,argu{1},argu{2},argu{3},argu{4});
elseif nb_fargin == 5
    param = feval(iso_function.f,argu{1},argu{2},argu{3},argu{4},argu{5});
elseif nb_fargin == 6
    param = feval(iso_function.f,argu{1},argu{2},argu{3},argu{4},argu{5},argu{6});
end
%--------------------------------------------------------------------------
% --- Output
if size(param,1) == 1 && size(param,2) ~= nb_elem
    iso_array = repmat(param,nb_elem,1);
else
    iso_array = param;
end
%--------------------------------------------------------------------------

