function validvarargin = f_validvarargin(vararginlist,validarglist)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

validvarargin = {};
k = 0;
for i = 1:length(vararginlist)/2
    if any(strcmpi(vararginlist{2*i-1},validarglist))
        k = k + 1;
        validvarargin{2*k-1} = vararginlist{2*i-1};
        validvarargin{2*k}   = vararginlist{2*i};
    end
end