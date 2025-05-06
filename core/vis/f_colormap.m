function f_colormap(varargin)
% F_COLORMAP plots arrows of vector field. 
%--------------------------------------------------------------------------
% f_colormap('');
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
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