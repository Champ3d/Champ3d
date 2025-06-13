function con = f_conhexa(varargin)
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

con.nbNo_inEl = 8;
con.nbNo_inEd = 2;
con.EdNo_inEl = [1 2; 1 4; 1 5; 2 3; 2 6; 3 4; 3 7; 4 8; 5 6; 5 8; 6 7; 7 8];
con.siNo_inEd = [+1, -1]; % w.r.t edge
con.FaNo_inEl = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 1 4 8 5]; % 
%-----
con.NoFa_ofEd = [6 4; 3 5; 1 2; 3 5; 1 2; 4 6; 1 2; 1 2; 6 4; 3 5; 3 5; 4 6]; % !!! F(i,~j) - circular
con.NoFa_ofFa = [6 3 4 5; 6 3 4 5; 6 1 4 2; 3 1 5 2; 4 1 6 2; 3 1 5 2]; % !!! F(i,~i+1) - circular
%-----
con.nbNo_inFa = [      4;       4;       4;       4;       4;       4];
con.FaType    = [      2;       2;       2;       2;       2;       2];
con.nbEd_inFa{1} = 4; % for FaType 1
con.nbEd_inFa{2} = 4; % for FaType 2
con.EdNo_inFa{1} = [1 2; 1 4; 2 3; 3 4]; % for FaType 1
con.EdNo_inFa{2} = [1 2; 1 4; 2 3; 3 4]; % for FaType 2
con.FaEd_inEl = [];
con.siFa_inEl = [];
con.siEd_inEl = [];
con.siEd_inFa{1} = [1 -1 1 1]; % w.r.t face for FaType 1
con.siEd_inFa{2} = [1 -1 1 1]; % w.r.t face for FaType 2
%-----
con.nbEd_inEl = size(con.EdNo_inEl,1);
con.nbFa_inEl = size(con.FaNo_inEl,1);
%----- Gauss points
con.U   = sqrt(3)/3*[-1 -1 -1 -1  1  1  1 1];
con.V   = sqrt(3)/3*[-1 -1  1  1 -1 -1  1 1];
con.W   = sqrt(3)/3*[-1  1 -1  1 -1  1 -1 1];
con.Weigh =         [ 1  1  1  1  1  1  1 1];
con.cU  = 0;
con.cV  = 0;
con.cW  = 0;
con.cWeigh  = 8; % 2x2x2
con.nbG = length(con.U);
%-----
con.N{1} = @(u,v,w) 1/8.*(1-u).*(1-v).*(1-w);
con.N{2} = @(u,v,w) 1/8.*(1+u).*(1-v).*(1-w);
con.N{3} = @(u,v,w) 1/8.*(1+u).*(1+v).*(1-w);
con.N{4} = @(u,v,w) 1/8.*(1-u).*(1+v).*(1-w);
con.N{5} = @(u,v,w) 1/8.*(1-u).*(1-v).*(1+w);
con.N{6} = @(u,v,w) 1/8.*(1+u).*(1-v).*(1+w);
con.N{7} = @(u,v,w) 1/8.*(1+u).*(1+v).*(1+w);
con.N{8} = @(u,v,w) 1/8.*(1-u).*(1+v).*(1+w);
con.gradNx = @(u,v,w) [-1/8.*(1-v).*(1-w); +1/8.*(1-v).*(1-w); +1/8.*(1+v).*(1-w); -1/8.*(1+v).*(1-w); -1/8.*(1-v).*(1+w); +1/8.*(1-v).*(1+w); +1/8.*(1+v).*(1+w); -1/8.*(1+v).*(1+w);];                       
con.gradNy = @(u,v,w) [-1/8.*(1-u).*(1-w); -1/8.*(1+u).*(1-w); +1/8.*(1+u).*(1-w); +1/8.*(1-u).*(1-w); -1/8.*(1-u).*(1+w); -1/8.*(1+u).*(1+w); +1/8.*(1+u).*(1+w); +1/8.*(1-u).*(1+w);];
con.gradNz = @(u,v,w) [-1/8.*(1-u).*(1-v); -1/8.*(1+u).*(1-v); -1/8.*(1+u).*(1+v); -1/8.*(1-u).*(1+v); +1/8.*(1-u).*(1-v); +1/8.*(1+u).*(1-v); +1/8.*(1+u).*(1+v); +1/8.*(1-u).*(1+v);];





