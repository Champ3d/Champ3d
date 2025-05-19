function coeftype = f_coeftype(coef,varargin)
% F_COEFTYPE
% coeftype supported :
% + numeric_iso_value
% + numeric_iso_array
% + numeric_gtensor_value
% + numeric_gtensor_array
% + numeric_ltensor_value
% + function_ltensor_array
% + function_iso_array
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'nb_elem','id_elem'};

% --- default input value
nb_elem = [];
id_elem = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
no_nb_elem_info = 0;
if isempty(id_elem) && isempty(nb_elem)
    no_nb_elem_info = 1;
elseif ~isempty(id_elem)
    nb_elem = length(id_elem);
end
%--------------------------------------------------------------------------
coeftype = [];
%--------------------------------------------------------------------------
if no_nb_elem_info
    if isa(coef,'numeric')
        sizecoef = size(coef);
        if numel(coef) == 1
            coeftype = 'numeric_iso_value';
        elseif sizecoef(1) == 1 || sizecoef(2) == 1
            coeftype = 'numeric_iso_array';
        elseif sizecoef(1) == 3 && sizecoef(2) == 3 && length(sizecoef) == 2
            coeftype = 'numeric_gtensor_value';
        elseif sizecoef(1) == 2 && sizecoef(2) == 2 && length(sizecoef) == 2
            coeftype = 'numeric_gtensor_value';
        elseif sizecoef(2) == 3 && sizecoef(3) == 3 && length(sizecoef) >= 3
            coeftype = 'numeric_gtensor_array';
        elseif sizecoef(2) == 2 && sizecoef(3) == 2 && length(sizecoef) >= 3
            coeftype = 'numeric_gtensor_array';
        else
            fprintf('coef = \n');
            disp(coef);
            error([mfilename ' : cannot define the type of the coefficient !']);
        end
    elseif isa(coef,'struct')
        % ---------------------------------------------------------------------
        if isfield(coef,'main_value') && isfield(coef,'main_dir')
            paramconfig = fieldnames(coef);
            for i = 1:length(paramconfig)
                paramtype = f_paramtype(coef.(paramconfig{i}));
                switch paramtype
                    case {'c3d_parameter_function','function'}
                        coeftype = 'function_ltensor_array';
                        break;
                    case {'numeric'}
                        coeftype = 'numeric_ltensor_value';
                end
            end
        % ---------------------------------------------------------------------
        elseif isfield(coef,'f') && ~isfield(coef,'main_value')
            if isa(coef.f,'function_handle')
                coeftype = 'function_iso_array';
            else
                error([mfilename ' : #coefficient.f must be a function_handle !']);
            end
        end
        % ---------------------------------------------------------------------
    else
        fprintf('coef = \n');
        disp(coef);
        error([mfilename ' : cannot define the type of the coefficient !']);
    end
end