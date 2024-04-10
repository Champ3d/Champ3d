function ltensor = f_make_ltensor(varargin)
% Allow to build a tensor from parameters with different dependency.
% type
% value
% x_value, y_value, z_value, angle_value
% main_value, ort1_value, ort2_value, main_dir, ort1_dir, ort2_dir
% rot_axis, rot_angle
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'type','value','x_value','y_value','z_value','angle_value',...
           'main_value','ort1_value','ort2_value','main_dir','ort1_dir','ort2_dir',...
           'rot_axis','rot_angle'};

% --- valid values of type
type_valid = {'isotropic','scalar','tensoroxy','ltensor'};

% --- default input value
type = [];
value = 0;
x_value = 0;
y_value = 0;
z_value = 0;
angle_value = 0;
main_value = 0;
ort1_value = 0;
ort2_value = 0;
main_dir = 0;
ort1_dir = 0;
ort2_dir = 0;
rot_axis = [];
rot_angle = [];
        
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~any(strcmpi(type,type_valid))
    error([mfilename ' : #type is not valid. Valid tensor types are ' strjoin(type_valid,', ') ' !']);
end
%--------------------------------------------------------------------------
ltensor.main_value = [];
ltensor.ort1_value = [];
ltensor.ort2_value = [];
ltensor.main_dir = [];
ltensor.ort1_dir = [];
ltensor.ort2_dir = [];
switch lower(type)
    case {'isotropic','scalar'}
        ltensor.main_value = value;
        ltensor.ort1_value = value;
        ltensor.ort2_value = value;
        ltensor.main_dir = [1 0 0];
        ltensor.ort1_dir = [0 1 0];
        ltensor.ort2_dir = [0 0 1];
    case 'tensoroxy'
        ltensor.main_value = x_value;
        ltensor.ort1_value = y_value;
        ltensor.ort2_value = z_value;
        ltensor.main_dir = [+cosd(angle_value) +sind(angle_value) 0];
        ltensor.ort1_dir = [-sind(angle_value) +cosd(angle_value) 0];
        ltensor.ort2_dir = [0 0 1];
    case 'ltensor'
        ltensor.main_value = main_value;
        ltensor.ort1_value = ort1_value;
        ltensor.ort2_value = ort2_value;
        if isempty(rot_axis) || isempty(rot_angle)
            ltensor.main_dir = main_dir;
            ltensor.ort1_dir = ort1_dir;
            ltensor.ort2_dir = ort2_dir;
        else
            ltensor.main_dir = f_rotaroundaxis(main_dir,'rot_axis',rot_axis,'angle',rot_angle);
            ltensor.ort1_dir = f_rotaroundaxis(ort1_dir,'rot_axis',rot_axis,'angle',rot_angle);
            ltensor.ort2_dir = f_rotaroundaxis(ort2_dir,'rot_axis',rot_axis,'angle',rot_angle);
        end
end

























