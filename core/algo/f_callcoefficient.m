function [coef_array, coef_array_type] = f_callcoefficient(c3dobj,varargin)
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
arglist = {'design3d','id_design3d','dom_type','id_dom',...
           'phydomobj','coefficient'};

% --- default input value
design3d = [];
id_design3d = [];
dom_type  = [];
id_dom    = [];
phydomobj = [];
coefficient = [];

% --- valid coefficient type
valid_coeftype = {'numeric_iso_value','numeric_iso_array','numeric_gtensor_value', ...
                  'numeric_gtensor_array','numeric_ltensor_value',...
                  'function_ltensor_array','function_iso_array'};

% --- default output value
coef_array = [];
coef_array_type  = [];

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
if isempty(coefficient) 
    coef = 1;
elseif isnumeric(coefficient)
    coef = coefficient;
else
    coef = phydomobj.(coefficient);
end
%--------------------------------------------------------------------------
phydomobj  = f_get_id(c3dobj,phydomobj);
%--------------------------------------------------------------------------
dim  = phydomobj.dimension;
%--------------------------------------------------------------------------
defined_on = phydomobj.defined_on;
if any(f_strcmpi(defined_on,'elem'))
    id_elem = phydomobj.id_elem;
    nb_elem = length(id_elem);
elseif any(f_strcmpi(defined_on,'face'))
    id_elem = phydomobj.id_face;
    nb_elem = length(id_elem);
elseif any(f_strcmpi(defined_on,'edge'))
    id_elem = phydomobj.id_edge;
    nb_elem = length(id_elem);
elseif any(f_strcmpi(defined_on,'node'))
    id_elem = phydomobj.id_node;
    nb_elem = length(id_elem);
end
%--------------------------------------------------------------------------
coeftype = f_coeftype(coef);
%--------------------------------------------------------------------------
switch coeftype
    case {'numeric_iso_value'}
        coef_array = repmat(coef,nb_elem,1);
        coef_array_type  = 'iso_array';
    case {'numeric_iso_array'}
        coef_array = coef;
        coef_array_type  = 'iso_array';
    case {'numeric_gtensor_value'}
        if dim == 3
            coef_array = reshape(repmat(coef,1,nb_elem),3,3,nb_elem);
        elseif dim == 2
            coef_array = reshape(repmat(coef,1,nb_elem),2,2,nb_elem);
        end
        coef_array = permute(coef_array,[3 1 2]);
        coef_array_type  = 'tensor_array';
    case {'numeric_gtensor_array'}
        coef_array = coef;
        coef_array_type  = 'tensor_array';
    case {'numeric_ltensor_value'}
        coef_array = f_gtensor(coef);
        coef_array_type  = 'tensor_array';
    case {'function_ltensor_array'}
        ltensor = f_evalltensor(c3dobj,'phydomobj',phydomobj,'ltensor',coef);
        coef_array = f_gtensor(ltensor);
        coef_array_type  = 'tensor_array';
    case {'function_iso_array'}
        coef_array = f_evalisofun(c3dobj,'phydomobj',phydomobj,'iso_function',coef);
        coef_array_type  = 'iso_array';
    otherwise
        f_display(coef);
        error([mfilename ' : coefficient type is not supported !']);
end