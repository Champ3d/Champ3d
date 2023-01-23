function con = f_contri(varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
con.nbNo_inEl = 3;
con.nbNo_inEd = 2;
con.nbNo_inFa = 2;
con.EdNo_inEl = [1 2; 1 3; 2 3];
con.siNo_inEd = [1 -1];   % w.r.t edge
con.siEd_inEl = [1 -1 1]; % w.r.t elem
con.siFa_inEl = [1 -1 1];
con.FaNo_inEl = [1 2; 1 3; 2 3]; % (F1) (F2) (F3)
%-----
con.NoFa_ofEd = [2 3; 1 3; 1 2]; % !!! F(i,~j) - circular
% con.NoFa_ofFa = [4 3 5 0; 4 3 5 0; 4 1 5 2; 3 1 5 2; 3 1 4 2]; % !!! F(i,~i+1) - circular
%-----
con.FaEd_inEl = [];
%-----
con.nbEd_inEl = size(con.EdNo_inEl,1);
con.nbFa_inEl = size(con.FaNo_inEl,1);
%----- Gauss points
con.U   =       [1/6  2/3  1/6];
con.V   =       [1/6  1/6  2/3];
con.Weigh =     [1/6  1/6  1/6];
con.cU  = 1/3;
con.cV  = 1/3;
con.cWeigh  = 1/2;
con.nbG = length(con.U);
%-----
con.N{1} = @(u,v) (1-u-v);
con.N{2} = @(u,v) (    u);
con.N{3} = @(u,v) (    v);
con.gradNx = @(u,v) [-u./u;   u./u;   0*u];
con.gradNy = @(u,v) [-u./u;    0*u;  u./u];




