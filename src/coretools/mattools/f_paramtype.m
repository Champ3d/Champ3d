function paramtype = f_paramtype(param)
% F_PARAMTYPE
% o-- param must be single parameter.
% r-- use f_make_parameter to make single param with dependency
% l-- Refer to f_coeftype to check physical behavior coefficient type.
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
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