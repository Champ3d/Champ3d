function [coef_array, coef_array_type] = f_coef_array(coef,varargin)
% F_COEF_ARRAY
% coef_array will be of size :
%   o nb_elem x 1
%   o nb_elem x 2 x 2
%   o nb_elem x 3 x 3
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
            tensor_type = 'a_1x1_tensor';
        elseif s2 == 1 && s1 > 1
            tensor_type = 'a_1x1_tensor_array';
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
    case {'a_1x1_tensor','a_scalar','a_1x1_tensor_array','a_scalar_array'}
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