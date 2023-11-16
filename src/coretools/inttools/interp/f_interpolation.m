function compute_node_value = f_interpolation(node,node_value,compute_node,varargin)
% F_INTERPOLATION builds the coef matrix ready to pass to integral computation.
%--------------------------------------------------------------------------
% FIXED INPUT
% node : sample points coordinates
%   o [2 x nb_points]
%   o [3 x nb_points]
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'method' : interpolation method
%   o 'linear'  -> by default
%   o 'natural' 
%   o 'nearest'
%--------------------------------------------------------------------------
% OUTPUT
% cmatrix : coefficient matrix
%   o 2D : 2 x 2 x nbElem
%   o 3D : 3 x 3 x nbElem
%--------------------------------------------------------------------------
% EXAMPLE
% compute_node_value = F_INTERPOLATION(node,node_value,compute_node);
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
arglist = {'node','node_value','compute_node','method'};

% --- default input value
method  = 'linear';

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------

switch size(node,1)
    case 2
        compute_node_value = griddata(node(1,:),node(2,:),node_value,...
                                      compute_node(1,:),compute_node(2,:), ...
                                      method);
    case 3
        compute_node_value = griddata(node(1,:),node(2,:),node(3,:),node_value,...
                                      compute_node(1,:),compute_node(2,:),compute_node(3,:), ...
                                      method);
end





















