function [coef_array, coef_array_type] = f_coef_array(coef,varargin)
% F_COEF_ARRAY
% coef_array will be of size :
%   o nb_elem x 1
%   o nb_elem x 2 x 2
%   o nb_elem x 3 x 3
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
if isempty(coef)
    coef_array = [];
    coef_array_type = [];
    return
end
%--------------------------------------------------------------------------
tensor_type = [];
size_gt = size(coef);
lensize_gt = length(size_gt);
%--------------------------------------------------------------------------
switch lensize_gt
    case 2
        s1 = size_gt(1);
        s2 = size_gt(2);
        if s1 == 2 && s2 == 2
            tensor_type = 'a_2x2_tensor';
        elseif s1 == 3 && s2 == 3
            tensor_type = 'a_3x3_tensor';
        elseif s2 == 1 && s1 == 1
            tensor_type = 'a_scalar';
        elseif s2 == 1 && s1 > 1
            tensor_type = 'a_scalar_array';
        else
            error([mfilename ' : check input dimension !']);
        end
    case 3
        s1 = size_gt(1);
        s2 = size_gt(2);
        s3 = size_gt(3);
        if s2 == 2 && s3 == 2
            tensor_type = 'a_2x2_tensor_array';
        elseif s2 == 3 && s3 == 3
            tensor_type = 'a_3x3_tensor_array';
        else
            error([mfilename ' : check input dimension !']);
        end
    otherwise
        error([mfilename ' : check tensor dimension, cannot work with 4 dim tensor !']);
end
%--------------------------------------------------------------------------
switch tensor_type
    case {'a_scalar','a_scalar_array'}
        coef_array = f_tocolv(coef);
        coef_array_type = 'iso_array';
    case {'a_2x2_tensor','a_3x3_tensor'}
        coef_array(1,:,:) = coef;
        coef_array_type = 'tensor_array';
    case {'a_2x2_tensor_array','a_3x3_tensor_array'}
        coef_array = coef;
        coef_array_type = 'tensor_array';
end
%--------------------------------------------------------------------------