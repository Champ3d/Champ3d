function con = f_contet(varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
con.nbNo_inEl = 4;
con.nbNo_inEd = 2;
con.nbNo_inFa = 3;
con.nbEd_inFa = 3;
con.EdNo_inEl = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
con.siNo_inEd = [1; -1]; % w.r.t edge
con.FaNo_inEl = [1 2 3; 1 2 4; 1 3 4; 2 3 4];
con.EdNo_inFa = [1 2; 1 3; 2 3];
con.FaEd_inEl = [1 2 4; 1 3 5; 2 3 6; 4 5 6]; % use natural order
con.siFa_inEl = 0;
con.siEd_inFa = [1 -1 1]; % w.r.t face
%-----
con.nbEd_inEl = size(con.EdNo_inEl,1);
con.nbFa_inEl = size(con.FaNo_inEl,1);








