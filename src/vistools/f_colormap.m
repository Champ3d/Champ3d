function f_colormap(varargin)
% F_COLORMAP plots arrows of vector field. 
%--------------------------------------------------------------------------
% f_colormap('');
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
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