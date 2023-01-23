function invtensor = f_invtensor(gtensor,varargin)
% F_INVTENSOR computes the inverse of 2x2 or 3x3 tensor or tensor array.
%--------------------------------------------------------------------------
% FIXED INPUT
% gtensor : tensor or tensor array
%    o [2 x 2]
%    o [3 x 3]
%    o [2 x 2 x nb_tensor]
%    o [3 x 3 x nb_tensor]
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% invtensor : tensor or tensor array
%    o [2 x 2]
%    o [3 x 3]
%    o [2 x 2 x nb_tensor]
%    o [3 x 3 x nb_tensor]
%--------------------------------------------------------------------------
% EXAMPLE
% invtensor = F_INVTENSOR(gtensor)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

atensor = 1; % 1 -> a tensor or 0 -> an array of tensor

if length(size(gtensor)) == 3
    atensor = 0;
elseif length(size(gtensor)) > 3
    error([mfilename ' : check tensor dimension, cannot inverse 4 dim tensor !']);
end

if atensor
    invtensor = inv(gtensor);
else
    switch size(gtensor,1)
        case 2
            % --- 
            invtensor = zeros(2,2,size(gtensor,3));
            % ---
            a11(1,:) = gtensor(1,1,:);
            a12(1,:) = gtensor(1,2,:);
            a21(1,:) = gtensor(2,1,:);
            a22(1,:) = gtensor(2,2,:);
            d = a11.*a22 - a21.*a12;
            idinversible = find(d);
            invtensor(1,1,idinversible) = +1./d(idinversible).*a22(idinversible);
            invtensor(1,2,idinversible) = -1./d(idinversible).*a12(idinversible);
            invtensor(2,1,idinversible) = -1./d(idinversible).*a21(idinversible);
            invtensor(2,2,idinversible) = +1./d(idinversible).*a11(idinversible);
        case 3
            % --- 
            invtensor = zeros(3,3,size(gtensor,3));
            % ---
            a11(1,:) = gtensor(1,1,:);
            a12(1,:) = gtensor(1,2,:);
            a13(1,:) = gtensor(1,3,:);
            a21(1,:) = gtensor(2,1,:);
            a22(1,:) = gtensor(2,2,:);
            a23(1,:) = gtensor(2,3,:);
            a31(1,:) = gtensor(3,1,:);
            a32(1,:) = gtensor(3,2,:);
            a33(1,:) = gtensor(3,3,:);
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
            invtensor(1,1,idinversible) = 1./d(idinversible).*A11(idinversible);
            invtensor(1,2,idinversible) = 1./d(idinversible).*A12(idinversible);
            invtensor(1,3,idinversible) = 1./d(idinversible).*A13(idinversible);
            invtensor(2,1,idinversible) = 1./d(idinversible).*A21(idinversible);
            invtensor(2,2,idinversible) = 1./d(idinversible).*A22(idinversible);
            invtensor(2,3,idinversible) = 1./d(idinversible).*A23(idinversible);
            invtensor(3,1,idinversible) = 1./d(idinversible).*A31(idinversible);
            invtensor(3,2,idinversible) = 1./d(idinversible).*A32(idinversible);
            invtensor(3,3,idinversible) = 1./d(idinversible).*A33(idinversible);
    end
end











