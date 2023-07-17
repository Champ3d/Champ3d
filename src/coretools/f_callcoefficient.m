function p_value = f_callcoefficient(c3dobj,varargin)
% F_CALLPARAMETER calculates and returns parameter value according to its dependency.
% p_value : array of values of the parameter computed for each element
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','id_design3d','dom_type','id_dom',...
           'phydomobj','parameter','parameter_type'};

% --- default input value
design3d = [];
id_design3d = [];
dom_type  = [];
id_dom    = [];
phydomobj = [];
coefficient = [];
parameter_type = [];

% --- default output value
p_value = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(phydomobj)
    if ~isempty(design3d) && ~isempty(id_design3d) && ~isempty(dom_type) && ~isempty(id_dom)
        phydomobj = c3dobj.(design3d).(id_design3d).(dom_type).(id_dom);
    else
        return;
    end
end
%--------------------------------------------------------------------------
coef = phydomobj.(coefficient);
%--------------------------------------------------------------------------
if isempty(parameter_type)
    if isfield(coef,'main_value') && isfield(coef,'main_dir')
        parameter_type = 'tensor';
    end
end
%--------------------------------------------------------------------------
if ~isstruct(coef)
    error([mfilename ': #' coefficient ' is not valid ! Use f_make_parameter !']);
end
% if ~isa(param.f,'function_handle')
%     error([mfilename ': #' parameter '.f must be a function_handle ! Use f_make_parameter !']);
% end
%--------------------------------------------------------------------------
id_mesh3d = phydomobj.id_mesh3d;
id_dom3d  = phydomobj.id_dom3d;
id_elem   = c3dobj.mesh3d.(id_mesh3d).(id_dom3d).id_elem;
nbElem    = length(id_elem);
%--------------------------------------------------------------------------
paramfields = fieldnames(phydomobj.(coefficient));
%--------------------------------------------------------------------------
for ipf = 1:length(paramfields)
%--------------------------------------------------------------------------
if nargin(param.f) == 0
    p_value = ones(1,nbElem) .* param.f();
else
    %----------------------------------------------------------------------
    nb_fargin = nargin(param.f);
    %----------------------------------------------------------------------
    alist = {};
    for ial = 1:nb_fargin
        alist{ial} = ['c3dobj' ...
                      '.' param.design3d{ial} ...
                      '.' param.id_design3d{ial} ...
                      '.' param.field{ial}];
    end
    %----------------------------------------------------------------------
    for ial = 1:nb_fargin
        argu{ial} = eval([alist{ial} '(:,id_elem);']);
    end
    %----------------------------------------------------------------------
    if nb_fargin == 1
        p_value = feval(param.f,argu{1});
    elseif nb_fargin == 2
        p_value = feval(param.f,argu{1},argu{2});
    elseif nb_fargin == 3
        p_value = feval(param.f,argu{1},argu{2},argu{3});
    elseif nb_fargin == 4
        p_value = feval(param.f,argu{1},argu{2},argu{3},argu{4});
    elseif nb_fargin == 5
        p_value = feval(param.f,argu{1},argu{2},argu{3},argu{4},argu{5});
    end
end
%--------------------------------------------------------------------------
if iscolumn(p_value)
    p_value = p_value.';
end
%--------------------------------------------------------------------------
%if isrow(eval(alist{ial}))
%    argu = [alist{ial} '(:,id_elem)'];
%elseif iscolumn(eval(alist{ial}))
%    argu = [alist{ial} '(id_elem,:)'];
%else
%    argu = [alist{ial} '(:,id_elem)'];
%end
%fform = 'feval(parameter.f';
%for ial = 1:nargin(param.f)
%    fform = [fform ',' argu];
%end
%fform = [fform ');'];


