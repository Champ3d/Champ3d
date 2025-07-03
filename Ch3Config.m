% -------------------------------------------------------------------------
% Change the value of the variables in properties 
% to match your own installation in your own OS system
% -------------------------------------------------------------------------
% for path : use single-double quote format '" ... "'
% to be able to include space and special characters
% -------------------------------------------------------------------------
% Typical values for macos
% LTSpiceExecutable  = '"/Applications/LTspice.app/Contents/MacOS/LTspice"'
% OpenSCADExecutable = '"/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"'
% GMSHExecutable = '"/Applications/Gmsh.app/Contents/MacOS/gmsh"'
% FEMMLocation = ''
% -------------------------------------------------------------------------
% Typical values for windows
% LTSpiceExecutable = '"C:/Program Files/LTC/LTspiceXVII/XVIIx64.exe"';
% OpenSCADExecutable
% GMSHExecutable
% FEMMLocation
% -------------------------------------------------------------------------
classdef Ch3Config
    properties (Constant)
        LTSpiceExecutable  = '"/Applications/LTspice.app/Contents/MacOS/LTspice"'
        OpenSCADExecutable = '"/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"'
        GMSHExecutable = '"/Applications/Gmsh.app/Contents/MacOS/gmsh"'
        FEMMLocation = ''
    end
end