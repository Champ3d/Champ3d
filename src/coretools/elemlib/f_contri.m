function con = f_contri(varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------
con.nbNo_inEl = 3;
con.nbNo_inEd = 2;
con.EdNo_inEl = [1 2; 1 3; 2 3];
con.siNo_inEd = [+1, -1]; % w.r.t edge
con.FaNo_inEl = con.EdNo_inEl; % face as edge
%-----
con.NoFa_ofEd = [2 3; 1 3; 1 2]; % !!! F(i,~j) - circular
%con.NoFa_ofFa = [6 3 4 5; 6 3 4 5; 6 1 4 2; 3 1 5 2; 4 1 6 2; 3 1 5 2]; % !!! F(i,~i+1) - circular
%-----
con.nbNo_inFa = [  2;   2;   2];
con.FaType    = [  1;   1;   1];
con.nbEd_inFa = [];
con.EdNo_inFa = [];
con.FaEd_inEl = [];
con.siEd_inEl = [1; -1; 1];
con.siFa_inEl = con.siEd_inEl; % upperface convention
con.siEd_inFa = [];
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




