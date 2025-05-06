function  set_up()
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
% get(groot, 'factory'); % shows all the factory values.
% get(groot, 'default'); % shows changed default values.
% use get(groot, 'factory') for all possible object property.
% remove factory- and replace with default-.

%--------------------------------------------------------------------------
if ispc
    addpath('C:\femm42\mfiles'); % !! may be changed to your own directory
elseif ismac
    fprintf('Under macOS : FEMM tools are not supported ! \n');
end
%--------------------------------------------------------------------------
Interpreter = 'tex'; % 'latex'
fontSize = 14;
fontName = 'Courier New';
cpmap = interp1([1 52 103 154 205 256],...
                [0 0 0; 0 0 .75; .5 0 .8; 1 .1 0; 1 .7 0; 1 1 0],1:256);
% ---
set(0,'DefaultAxesTickLabelInterpreter',Interpreter);
set(0,'DefaultColorbarTickLabelInterpreter',Interpreter);
set(0,'DefaultTextInterpreter',Interpreter);
set(0,'DefaultTextarrowshapeInterpreter',Interpreter);
set(0,'DefaultTextboxshapeInterpreter',Interpreter);
set(0,'DefaultLegendInterpreter',Interpreter);
% ---
set(0,'DefaultAxesFontName',fontName);
set(0,'DefaultColorbarFontName',fontName);
set(0,'DefaultLegendFontName',fontName);
set(0,'DefaultTextFontName',fontName);
set(0,'DefaultTextarrowshapeFontName',fontName);
set(0,'DefaultTextboxshapeFontName',fontName);
% ---
set(0,'DefaultColorbarFontSize',fontSize);
set(0,'DefaultAxesFontSize',fontSize)
set(0,'DefaultLegendFontSize',fontSize);
set(0,'DefaultTextarrowshapeFontSize',fontSize);
set(0,'DefaultTextboxshapeFontSize',fontSize);
set(0,'DefaultTextFontSize',fontSize);
% ---
set(0,'DefaultFigureColormap', cpmap);

end