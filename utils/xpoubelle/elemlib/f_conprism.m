function con = f_conprism(varargin)
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
con.nbNo_inEl = 6;
con.nbNo_inEd = 2;
con.EdNo_inEl = [1 2; 1 3; 1 4; 2 3; 2 5; 3 6; 4 5; 4 6; 5 6];
con.siNo_inEd = [+1, -1]; % w.r.t edge
con.FaNo_inEl = [1 2 3 0; 4 5 6 0; 1 2 5 4; 1 3 6 4; 2 3 6 5]; % tri first then quad
%-----
con.NoFa_ofEd = [4 5; 3 5; 1 2; 3 4; 1 2; 1 2; 4 5; 3 5; 3 4]; % !!! F(i,~j) - circular
con.NoFa_ofFa = [4 3 5 0; 4 3 5 0; 4 1 5 2; 3 1 5 2; 3 1 4 2]; % !!! F(i,~i+1) - circular
%-----
con.nbNo_inFa = [      3;       3;       4;       4;       4];
con.FaType    = [      1;       1;       2;       2;       2];
con.nbEd_inFa{1} = 3; % for FaType 1
con.nbEd_inFa{2} = 4; % for FaType 2
con.EdNo_inFa{1} = [1 2; 1 3; 2 3];      % for FaType 1
con.EdNo_inFa{2} = [1 2; 1 4; 2 3; 3 4]; % for FaType 2
con.FaEd_inEl = [];
con.siFa_inEl = [];
con.siEd_inEl = [];
con.siEd_inFa{1} = [1 -1 1];   % w.r.t face for FaType 1
con.siEd_inFa{2} = [1 -1 1 1]; % w.r.t face for FaType 2
%-----
con.nbEd_inEl = size(con.EdNo_inEl,1);
con.nbFa_inEl = size(con.FaNo_inEl,1);
%----- Gauss points
con.U   =       1/2*[ 1  1  0  1  1  0];
con.V   =       1/2*[ 1  0  1  1  0  1];
con.W   = sqrt(3)/3*[-1 -1 -1  1  1  1];
con.Weigh =     1/6*[ 1  1  1  1  1  1];
con.cU  = 1/3;
con.cV  = 1/3;
con.cW  = 0;
con.cWeigh  = 1;
con.nbG = length(con.U);
%-----
con.N{1} = @(u,v,w) 1/2.*(1-u-v).*(1-w);
con.N{2} = @(u,v,w) 1/2.*(    u).*(1-w);
con.N{3} = @(u,v,w) 1/2.*(    v).*(1-w);
con.N{4} = @(u,v,w) 1/2.*(1-u-v).*(1+w);
con.N{5} = @(u,v,w) 1/2.*(    u).*(1+w);
con.N{6} = @(u,v,w) 1/2.*(    v).*(1+w);
con.gradNx = @(u,v,w) [w/2 - 1/2;       1/2 - w/2;       0*u;      -w/2 - 1/2; w/2 + 1/2;       0*u];
con.gradNy = @(u,v,w) [w/2 - 1/2;             0*v; 1/2 - w/2;      -w/2 - 1/2;       0*v; w/2 + 1/2];
con.gradNz = @(u,v,w) [u/2 + v/2 - 1/2;      -u/2;      -v/2; 1/2 - u/2 - v/2;       u/2;       v/2];

end

