function f_femm_analyze(n)
%--------------------------------------------------------------------------
% Call mi_analyze
% FEMM
% Author : David Meeker
% Copyright (C) 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

tic;
f_fprintf(0,'Solving 2d problem with FEMM',0,'\n');
% ---
mi_analyze(n);
% --- Log message
f_fprintf(0, '--- in',...
          1, toc,...
          0, 's \n');