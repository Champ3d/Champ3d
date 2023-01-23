function [mat,imat] = f_unique(mat,varargin)
% F_UNIQUE returns the unique row (or column) of an 2D array.
%--------------------------------------------------------------------------
% [mat,imat] = f_unique(mat,'urow');
% [mat,imat] = f_unique(mat,'ucol');
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
datin = [];
if nargin >= 1
    if length(size(mat)) > 2
        error([mfilename ': Cannot deal with 3 dimensional matrix!'])
    end
    
    if size(mat,1) == 1 | size(mat,2) == 1
        [mat,imat] = unique(mat);
        return
    end
    
    if  nargin > 1
        datin.(varargin{1}) = 1;
    else
        datin.urow = 1;
    end
    
    if isfield(datin,'urow') % unique row
        smat = sort(mat);
        dim  = size(mat,1);
        len  = size(mat,2);
        su   = zeros(1,len);
        for i = 1:dim
            su = su + smat(i,:) .* (pi^(i-1));
        end
        [~,imat] = unique(su);
        mat = mat(:,imat);
    elseif isfield(datin,'ucol') % unique col
        smat = sort(mat.');
        dim = size(mat,1);
        len = size(mat,2);
        su  = zeros(1,len);
        for i = 1:dim
            su = su + smat(i,:) .* (pi^(i-1));
        end
        [~,imat] = unique(su);
        mat = mat(imat,:);
    end
end

end