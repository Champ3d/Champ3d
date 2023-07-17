function gtensor = f_make_ltensor(varargin)
% Allow to build a tensor from parameters with different dependency.
% type
% value
% x_value, y_value, z_value, angle_value
% main_value, ort1_value, ort2_value, main_dir, ort1_dir, ort2_dir
% rot_axis, rot_angle
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'type','value','x_value','y_value','z_value','angle_value',...
           'main_value','ort1_value','ort2_value','main_dir','ort1_dir','ort2_dir',...
           'rot_axis','rot_angle'};

% --- valid values of type
type_valid = {'isotropic','scalar','tensoroxy','gtensor'};

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

if sum(strcmpi(type_valid,type)) == 0
    error([mfilename ': valid tensor types are ' strjoin(type_valid,', ') ' !']);
end

%--------------------------------------------------------------------------
gtensor.main_value = [];
gtensor.ort1_value = [];
gtensor.ort2_value = [];
gtensor.main_dir = [];
gtensor.ort1_dir = [];
gtensor.ort2_dir = [];
switch lower(type)
    case {'isotropic','scalar'}
        gtensor.main_value = value;
        gtensor.ort1_value = value;
        gtensor.ort2_value = value;
        gtensor.main_dir = [1 0 0];
        gtensor.ort1_dir = [0 1 0];
        gtensor.ort2_dir = [0 0 1];
    case 'tensoroxy'
        gtensor.main_value = x_value;
        gtensor.ort1_value = y_value;
        gtensor.ort2_value = z_value;
        gtensor.main_dir = [+cosd(angle_value) +sind(angle_value) 0];
        gtensor.ort1_dir = [-sind(angle_value) +cosd(angle_value) 0];
        gtensor.ort2_dir = [0 0 1];
    case 'gtensor'
        gtensor.main_value = main_value;
        gtensor.ort1_value = ort1_value;
        gtensor.ort2_value = ort2_value;
        if isempty(rot_axis) || isempty(rot_angle)
            gtensor.main_dir = main_dir;
            gtensor.ort1_dir = ort1_dir;
            gtensor.ort2_dir = ort2_dir;
        else
            gtensor.main_dir = f_rotaroundaxis(main_dir,'rot_axis',rot_axis,'angle',rot_angle);
            gtensor.ort1_dir = f_rotaroundaxis(ort1_dir,'rot_axis',rot_axis,'angle',rot_angle);
            gtensor.ort2_dir = f_rotaroundaxis(ort2_dir,'rot_axis',rot_axis,'angle',rot_angle);
        end
end

























