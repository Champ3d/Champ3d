function design3d = f_add_physical_problem(design3d,varargin)
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

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','physics','formulation','frequency'};

% --- default input value
physics  = 'no_physics';
formulation   = 'no_formulation';
frequency = 0;

%--------------------------------------------------------------------------
% if ~isfield(design3d,'physics')
%     iec = 0;
% else
%     iec = length(design3d.physics);
% end

% --- default input value
% id_physics = ['physics' num2str(iec+1)];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No physics to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

for i = 1:nargin/2
    design3d.(physics).formulation = formulation;
    design3d.(physics).frequency   = frequency;
end





