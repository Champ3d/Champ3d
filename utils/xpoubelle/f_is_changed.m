%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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

function ischanged = f_is_changed(v1,v2,args)
arguments
    v1
    v2
    args.tol = 1e-9
end
% ---
tol = args.tol;
% ---
ischanged = 0;
% ---
s1 = size(v1);
s2 = size(v2);
% ---
if length(s1) ~= length(s2)
    ischanged = 1;
    return
elseif any(s1 - s2)
    ischanged = 1;
    return
end
% ---
if any((v1 - v2) < -tol) || any((v1 - v2) > +tol)
    ischanged = 1;
end
