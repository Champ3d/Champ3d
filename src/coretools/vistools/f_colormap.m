function f_colormap(varargin)
% F_COLORMAP plots arrows of vector field. 
%--------------------------------------------------------------------------
% f_colormap('');
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

cmap = 'champ3d';
nbcolor = 256;

for i = 1:nargin/2
    eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
end

if nargin > 0
    cmap = varargin{1};
end

switch lower(cmap)
    case 'champ3d'
        cpmap = interp1([1 52 103 154 205 256],...
                    [0 0 0; 0 0 .75; .5 0 .8; 1 .1 0; 1 .7 0; 1 1 0],1:256);
        colormap(cpmap(round(linspace(1,256,nbcolor)),:));
end