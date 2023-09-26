function paramtype = f_paramtype(param)
% F_PARAMTYPE
% o-- param must be single parameter.
% r-- use f_make_parameter to make single param with dependency
% l-- Refer to f_coeftype to check physical behavior coefficient type.
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

paramtype = [];

if isa(param,'numeric')
    paramtype = 'numeric';
elseif isa(param,'struct') 
    % ---------------------------------------------------------------------
    if isfield(param,'f')
        if isa(param.f,'function_handle') && all(isfield(param,{'depend_on'}))
            paramtype = 'c3d_parameter_function';
        end
    end
else
    fprintf('param = \n');
    disp(param);
    error([mfilename ': the parameter is not valid ! Use f_make_parameter !']);
end