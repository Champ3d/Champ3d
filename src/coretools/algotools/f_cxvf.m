function vfout = f_cxvf(coef,vf,varargin)
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
arglist = {'options'};

% --- default input value
options = 'rowv'; % 'rowv', 'colv'

% --- default output value
vfout = 0.*vf;

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
[coef_array, coef_array_type] = f_tensor_array(coef);
coef_array = squeeze(coef_array);
%--------------------------------------------------------------------------
if any(f_strcmpi(coef_array_type,{'iso_array'}))
    vfout = coef_array.' .* vf;
elseif any(strcmpi(coef_array_type,{'tensor_array'}))
    if length(size(coef_array)) == 2
        vfout = coef_array * vf;
    elseif length(size(coef_array)) > 2
        for i = 1:3
            vfout(i,:) = sum(squeeze(coef_array(:,i,1:3)).' .* vf);
        end
    end
end










