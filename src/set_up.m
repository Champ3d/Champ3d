function  set_up()
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
% get(groot, 'factory'); % shows all the factory values.
% get(groot, 'default'); % shows changed default values.
% use get(groot, 'factory') for all possible object property.
% remove factory- and replace with default-.

%--------------------------------------------------------------------------
if ispc
    addpath('C:\femm42\mfiles'); % !! may be changed to your own directory
elseif ismac
    fprintf('Under iOS : FEMM tools are not supported ! \n');
end
%--------------------------------------------------------------------------
Interpreter = 'tex'; % 'latex'
fontSize = 14;
fontName = 'Tahoma';
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