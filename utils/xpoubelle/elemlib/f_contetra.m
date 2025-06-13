function con = f_contetra(varargin)
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
con.nbNo_inEl = 4;
con.nbNo_inEd = 2;
con.EdNo_inEl = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
con.siNo_inEd = [+1, -1]; % w.r.t edge
con.FaNo_inEl = [1 2 3; 1 2 4; 1 3 4; 2 3 4]; % 
%-----
con.NoFa_ofEd = [3 4; 2 4; 1 4; 2 3; 1 3; 1 2]; % !!! F(i,~j) - circular
con.NoFa_ofFa = [3 2 4; 3 1 4; 2 1 4; 2 1 3]; % !!! F(i,~i+1) - circular
%-----
con.nbNo_inFa = [    3;     3;     3;     3];
con.FaType    = [    1;     1;     1;     1];
con.nbEd_inFa{1} = 3; % for FaType 1
con.nbEd_inFa{2} = 3; % for FaType 2
con.EdNo_inFa{1} = [1 2; 1 3; 2 3]; % for FaType 1
con.EdNo_inFa{2} = [1 2; 1 3; 2 3]; % for FaType 2
con.FaEd_inEl = [];
con.siFa_inEl = [];
con.siEd_inEl = [];
con.siEd_inFa{1} = [1 -1 1]; % w.r.t face for FaType 1
con.siEd_inFa{2} = [1 -1 1]; % w.r.t face for FaType 2
%-----
con.nbEd_inEl = size(con.EdNo_inEl,1);
con.nbFa_inEl = size(con.FaNo_inEl,1);
%----- Gauss points
a = (5 - sqrt(5)) / 20;
b = (5 + 3 * sqrt(5)) / 20;
con.U   = [a a a b];
con.V   = [a a b a];
con.W   = [a b a a];
con.Weigh = 1/24 * [1  1  1  1];
con.cU  = 1/4;
con.cV  = 1/4;
con.cW  = 1/4;
con.cWeigh  = 1;
con.nbG = length(con.U);
%-----
con.N{1} = @(u,v,w) 1-u-v-w;
con.N{2} = @(u,v,w) u;
con.N{3} = @(u,v,w) v;
con.N{4} = @(u,v,w) w;
con.gradNx = @(u,v,w) [-1 + 0*u; 1 + 0*u;     0*u;     0*u];                       
con.gradNy = @(u,v,w) [-1 + 0*v;     0*v; 1 + 0*v;     0*v];
con.gradNz = @(u,v,w) [-1 + 0*w;     0*w;     0*w; 1 + 0*w];








