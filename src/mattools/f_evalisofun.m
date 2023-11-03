function iso_array = f_evalisofun(c3dobj,varargin)
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
phydomobj = f_get_id(c3dobj,phydomobj);
id_elem   = phydomobj.id_elem;
nb_elem   = length(id_elem);
%--------------------------------------------------------------------------
paramtype = f_paramtype(iso_function);
%--------------------------------------------------------------------------
if ~any(strcmpi(paramtype,{'c3d_parameter_function'}))
    error([mfilename ' : this iso_function is not supported. Use f_make_parameter ! \n']);
end
%--------------------------------------------------------------------------
nb_fargin = f_nargin(iso_function.f);
%--------------------------------------------------------------------------
alist = {};
for ial = 1:nb_fargin
    depon = iso_function.depend_on{ial};
    if isempty(depon)
        alist{ial} = depon;
    else
        alist{ial} = f_cargpath(c3dobj,'phydomobj',phydomobj,'arg_name',depon);
    end
end
%--------------------------------------------------------------------------
varargin_list = iso_function.varargin_list;
%--------------------------------------------------------------------------
argu = {};
for ial = 1:nb_fargin
    argu{ial} = eval([alist{ial} '(:,id_elem);']);
end
%--------------------------------------------------------------------------
if any(strcmpi(iso_function.coef_type,{'array'}))
    param = f_feval(iso_function.f,'argument_array',argu,'varargin_list',varargin_list);
else
    param = f_foreach(iso_function.f,'argument_array',argu,'varargin_list',varargin_list);
end
%--------------------------------------------------------------------------
param(isnan(param)) = 0;
%--------------------------------------------------------------------------
% --- Output
if size(param,1) == 1 && size(param,2) ~= nb_elem
    iso_array = repmat(param,nb_elem,1);
elseif size(param,1) ~= nb_elem && size(param,2) == nb_elem
    iso_array = param.';
else
    iso_array = param;
end
%--------------------------------------------------------------------------

