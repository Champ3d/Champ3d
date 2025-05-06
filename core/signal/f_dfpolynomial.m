%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function dfx = f_dfpolynomial(fx)

% --- keeped data for the derivative of piece-wise polynomial
dfx.form = fx.form;
dfx.breaks = fx.breaks;
dfx.pieces = fx.pieces;
dfx.dim = fx.dim;
% --- derivative -> lower order
dfx.order = fx.order - 1;
% --- coef
ofxt = fx.order;
nbpt = size(fx.coefs, 1);
dfx.coefs = zeros(nbpt, ofxt-1);
for i = 1 : ofxt-1
    % --- highest order first
    dfx.coefs(:,i) = (ofxt-i) * fx.coefs(:,i);
end
% ---

end