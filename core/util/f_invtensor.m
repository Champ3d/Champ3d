function invtensor = f_invtensor(gtensor,varargin)
% F_INVTENSOR computes the inverse of 2x2 or 3x3 tensor or tensor array.
%--------------------------------------------------------------------------
% FIXED INPUT
% gtensor : tensor or tensor array
%    o [1 x 1] --> scalar
%    o [2 x 2]
%    o [3 x 3]
%    o [nb_tensor x 1]
%    o [nb_tensor x 2 x 2]
%    o [nb_tensor x 3 x 3]
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% invtensor : tensor or tensor array
%    o [2 x 2]
%    o [3 x 3]
%    o [nb_tensor x 1]
%    o [nb_tensor x 2 x 2]
%    o [nb_tensor x 3 x 3]
%--------------------------------------------------------------------------
% EXAMPLE
% invtensor = F_INVTENSOR(gtensor)
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
tensor_type = [];
size_gt = size(gtensor);
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
        error([mfilename ' : check tensor dimension, cannot inverse 4 dim tensor !']);
end
%--------------------------------------------------------------------------
switch tensor_type
    case {'a_scalar','a_scalar_array'}
        % --- 
        invtensor = zeros(s1,1);
        % ---
        idinversible = find(gtensor);
        invtensor(idinversible,1) = 1./gtensor(idinversible,1);
    case {'a_2x2_tensor','a_3x3_tensor'}
        if det(gtensor) > 0
            invtensor = inv(gtensor);
        else
            invtensor = 0 .* gtensor;
        end
    case {'a_2x2_tensor_array'}
        % --- 
        invtensor = zeros(s1,2,2);
        % ---
        a11(1,:) = gtensor(:,1,1);
        a12(1,:) = gtensor(:,1,2);
        a21(1,:) = gtensor(:,2,1);
        a22(1,:) = gtensor(:,2,2);
        d = a11.*a22 - a21.*a12;
        idinversible = find(d);
        invtensor(idinversible,1,1) = +1./d(idinversible).*a22(idinversible);
        invtensor(idinversible,1,2) = -1./d(idinversible).*a12(idinversible);
        invtensor(idinversible,2,1) = -1./d(idinversible).*a21(idinversible);
        invtensor(idinversible,2,2) = +1./d(idinversible).*a11(idinversible);
    case {'a_3x3_tensor_array'}
        % --- 
        invtensor = zeros(s1,3,3);
        % ---
        a11(1,:) = gtensor(:,1,1);
        a12(1,:) = gtensor(:,1,2);
        a13(1,:) = gtensor(:,1,3);
        a21(1,:) = gtensor(:,2,1);
        a22(1,:) = gtensor(:,2,2);
        a23(1,:) = gtensor(:,2,3);
        a31(1,:) = gtensor(:,3,1);
        a32(1,:) = gtensor(:,3,2);
        a33(1,:) = gtensor(:,3,3);
        A11 = a22.*a33 - a23.*a32;
        A12 = a32.*a13 - a12.*a33;
        A13 = a12.*a23 - a13.*a22;
        A21 = a23.*a31 - a21.*a33;
        A22 = a33.*a11 - a31.*a13;
        A23 = a13.*a21 - a23.*a11;
        A31 = a21.*a32 - a31.*a22;
        A32 = a31.*a12 - a32.*a11;
        A33 = a11.*a22 - a12.*a21;
        d = a11.*a22.*a33 + a21.*a32.*a13 + a31.*a12.*a23 - ...
            a11.*a32.*a23 - a31.*a22.*a13 - a21.*a12.*a33;
        idinversible = find(d);
        invtensor(idinversible,1,1) = 1./d(idinversible).*A11(idinversible);
        invtensor(idinversible,1,2) = 1./d(idinversible).*A12(idinversible);
        invtensor(idinversible,1,3) = 1./d(idinversible).*A13(idinversible);
        invtensor(idinversible,2,1) = 1./d(idinversible).*A21(idinversible);
        invtensor(idinversible,2,2) = 1./d(idinversible).*A22(idinversible);
        invtensor(idinversible,2,3) = 1./d(idinversible).*A23(idinversible);
        invtensor(idinversible,3,1) = 1./d(idinversible).*A31(idinversible);
        invtensor(idinversible,3,2) = 1./d(idinversible).*A32(idinversible);
        invtensor(idinversible,3,3) = 1./d(idinversible).*A33(idinversible);
end
