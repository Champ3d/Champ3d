function con = f_conquad(varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
con.nbNo_inEl = 4;
con.nbNo_inEd = 2;
con.EdNo_inEl = [1 2; 1 4; 2 3; 3 4];
con.siNo_inEd = [+1, -1]; % w.r.t edge
con.FaNo_inEl = [1 2; 1 4; 2 3; 3 4]; % face as edge
%-----
con.NoFa_ofEd = [2 3; 1 4; 1 4; 3 2]; % !!! F(i,~j) - circular
%con.NoFa_ofFa = [6 3 4 5; 6 3 4 5; 6 1 4 2; 3 1 5 2; 4 1 6 2; 3 1 5 2]; % !!! F(i,~i+1) - circular
%-----
con.nbNo_inFa = [  2;   2;   2;   2];
con.FaType    = [  1;   1;   1;   1];
con.nbEd_inFa{1} = 1; % for FaType 1
con.nbEd_inFa{2} = 1; % for FaType 2
con.EdNo_inFa{1} = [1 2]; % for FaType 1
con.EdNo_inFa{2} = [1 2]; % for FaType 2
con.FaEd_inEl = [];
con.siFa_inEl = [1; -1; 1; 1]; % upperface convention
con.siEd_inEl = [1; -1; 1; 1];
con.siEd_inFa{1} = [1]; % w.r.t face for FaType 1
con.siEd_inFa{2} = [1]; % w.r.t face for FaType 2
%-----
con.nbEd_inEl = size(con.EdNo_inEl,1);
con.nbFa_inEl = size(con.FaNo_inEl,1);
%----- Gauss points
con.U     = 1/sqrt(3)*[-1 -1  1  1];
con.V     = 1/sqrt(3)*[-1  1 -1  1];
con.Weigh =           [ 1  1  1  1];
con.cU  = 0;
con.cV  = 0;
con.cWeigh  = 4;
con.nbG = length(con.U);
%-----
con.N{1} = @(u,v) 1/4 * (1-u) .* (1-v);
con.N{2} = @(u,v) 1/4 * (1+u) .* (1-v);
con.N{3} = @(u,v) 1/4 * (1+u) .* (1+v);
con.N{4} = @(u,v) 1/4 * (1-u) .* (1+v);
con.gradNx = @(u,v) [(-1+v)./4;  (1-v)./4; (1+v)./4; (-1-v)./4];
con.gradNy = @(u,v) [(-1+u)./4; (-1-u)./4; (1+u)./4;  (1-u)./4];





