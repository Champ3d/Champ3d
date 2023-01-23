function design3d = f_add_physical_loop(design3d,varargin)
% 'physics' : 
%     + 'magnetodynamic_jw'   ->  default formulation: 'aphi_jw'
%          o 'frequency'
%     + 'magnetodynamic_time' ->  default formulation: 'aphi_time'
%          o 'fixed_time_step'
%               - 'delta_t'
%          o 'variable_time_step'
%     + 'magnetostatic_jw'    ->  default formulation: 'aphi_jw'
%     + 'magnetostatic_time'  ->  default formulation: 'aphi_time'
%     + 'electrokinetic'      ->  default formulation: 'v_jw'
%     + 'heat_transfer'       ->  default formulation: 'heat'
% 'formulation' : 
%     + 'aphi_time'
%     + 'aphi_jw'
%     + 'tome_time'
%     + 'tome_jw'
%     + 'heat'
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
