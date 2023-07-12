function paramtype = f_paramtype(param)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

if isa(param,'numeric')
    if numel(param) == 1
        paramtype = 'num_iso_coef';
    else
        paramtype = 'num_iso_array';
    end
elseif isa(param,'function_handle')
    paramtype = 'fun_iso_array';
elseif isa(param,'struct')
    paramtype = 'num_aniso_coef';
    paramconfig = fieldnames(param);
    for i = 1:length(paramconfig)
        if isa(param.(paramconfig),'function_handle')
            paramtype = 'fun_aniso_array';
            break;
        end
    end
end