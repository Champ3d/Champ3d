% -------------------------------------------------------------------------
% Change the value of the variables in properties 
% to match your own installation in your own OS system
% -------------------------------------------------------------------------
% for path : use single-double quote format '" ... "'
% to be able to include space and special characters
% -------------------------------------------------------------------------
% ExecutableOpenSCADLocation : link to executable file not folder
% ExecutableLTSpiceLocation  : link to executable file not folder
% ExecutableFEMMLocation     : link to executable file not folder
% -------------------------------------------------------------------------
% Typical values for macos
% ExecutableLTSpiceLocation = '"/Applications/LTspice.app/Contents/MacOS/LTspice"'
% ExecutableOpenSCADLocation = '"/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"'
% ExecutableFEMMLocation = ''
% -------------------------------------------------------------------------
% Typical values for windows
% ExecutableLTSpiceLocation = '"C:/Program Files/LTC/LTspiceXVII/XVIIx64.exe"';
% ExecutableOpenSCADLocation 
% ExecutableFEMMLocation
% -------------------------------------------------------------------------
classdef Ch3Config
    properties (Constant)
        ExecutableLTSpiceLocation = '"/Applications/LTspice.app/Contents/MacOS/LTspice"'
        ExecutableOpenSCADLocation = '"/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"'
        ExecutableFEMMLocation = ''
    end
end