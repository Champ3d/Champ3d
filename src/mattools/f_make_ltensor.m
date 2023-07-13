function gtensor = f_make_ltensor(varargin)
% Allow to build a tensor from parameters with different dependency.
% type
% value
% x_value, y_value, z_value, angle_value
% main_value, ort1_value, ort2_value, main_dir, ort1_dir, ort2_dir
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'type','value','x_value','y_value','z_value','angle_value',...
           'main_value','ort1_value','ort2_value','main_dir','ort1_dir','ort2_dir',...
           'rot_axis','angle'};

% --- valid values of type
type_valid = {'isotropic','scalar','tensoroxy','gtensor'};

% --- default input value
datin.type = [];
datin.value = 0;
datin.x_value = 0;
datin.y_value = 0;
datin.z_value = 0;
datin.angle_value = 0;
datin.main_value = 0;
datin.ort1_value = 0;
datin.ort2_value = 0;
datin.main_dir = 0;
datin.ort1_dir = 0;
datin.ort2_dir = 0;
datin.rot_axis = [];
datin.angle = [];
        
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:nargin/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        datin.(lower(varargin{2*i-1})) = varargin{2*i};
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

if sum(strcmpi(type_valid,datin.type)) == 0
    error([mfilename ': valid types are ' strjoin(type_valid,', ') ' !']);
end

%--------------------------------------------------------------------------
gtensor.main_value = [];
gtensor.ort1_value = [];
gtensor.ort2_value = [];
gtensor.main_dir = [];
gtensor.ort1_dir = [];
gtensor.ort2_dir = [];
switch lower(datin.type)
    case {'isotropic','scalar'}
        gtensor.main_value = datin.value;
        gtensor.ort1_value = datin.value;
        gtensor.ort2_value = datin.value;
        gtensor.main_dir = [1 0 0];
        gtensor.ort1_dir = [0 1 0];
        gtensor.ort2_dir = [0 0 1];
    case 'tensoroxy'
        gtensor.main_value = datin.x_value;
        gtensor.ort1_value = datin.y_value;
        gtensor.ort2_value = datin.z_value;
        gtensor.main_dir = [+cosd(datin.angle_value) +sind(datin.angle_value) 0];
        gtensor.ort1_dir = [-sind(datin.angle_value) +cosd(datin.angle_value) 0];
        gtensor.ort2_dir = [0 0 1];
    case 'gtensor'
        gtensor.main_value = datin.main_value;
        gtensor.ort1_value = datin.ort1_value;
        gtensor.ort2_value = datin.ort2_value;
        if isempty(datin.rot_axis) || isempty(datin.angle)
            gtensor.main_dir = datin.main_dir;
            gtensor.ort1_dir = datin.ort1_dir;
            gtensor.ort2_dir = datin.ort2_dir;
        else
            gtensor.main_dir = f_rotaroundaxis(datin.main_dir,'rot_axis',datin.rot_axis,'angle',datin.angle);
            gtensor.ort1_dir = f_rotaroundaxis(datin.ort1_dir,'rot_axis',datin.rot_axis,'angle',datin.angle);
            gtensor.ort2_dir = f_rotaroundaxis(datin.ort2_dir,'rot_axis',datin.rot_axis,'angle',datin.angle);
        end
end

























