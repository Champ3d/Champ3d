function paramtype = f_paramtype(param)
% F_PARAMTYPE
% o-- param must be single parameter.
% r-- use f_make_parameter to make single param with dependency
% l-- Refer to f_coeftype to check physical behavior coefficient type.
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

paramtype = [];

if isa(param,'numeric')
    paramtype = 'numeric';
elseif isa(param,'struct') 
    % ---------------------------------------------------------------------
    if isfield(param,'f')
        if isa(param.f,'function_handle')
            paramtype = 'function';
            if isfield(param,{'depend_on'})
                paramtype = 'c3d_parameter_function';
            end
        end
    end
else
    fprintf('param = \n');
    disp(param);
    error([mfilename ': the parameter is not valid ! Use f_make_coef !']);
end